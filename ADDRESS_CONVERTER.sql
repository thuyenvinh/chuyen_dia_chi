Create Or Replace Package ADDRESS_CONVERTER As

  Type T_RESULT Is Record(
    SUCCESS           Number(1),
    ORIGINAL_ADDRESS  Nvarchar2(500),
    CONVERTED_ADDRESS Nvarchar2(500),
    MESSAGE           Nvarchar2(200));

  Function REMOVE_ACCENTS(P_STRING In Varchar2) Return Varchar2;

  Function NORMALIZE_TEXT(P_TEXT Nvarchar2) Return Nvarchar2;

  Function CONVERT_ADDRESS(P_ADDRESS In Nvarchar2) Return T_RESULT;

End ADDRESS_CONVERTER;
-------------
Create Or Replace Package Body ADDRESS_CONVERTER As

  Function NORMALIZE_TEXT(P_TEXT Nvarchar2) Return Nvarchar2 Is
    L_TEXT Nvarchar2(500);
  Begin
    --L_TEXT := LOWER(Trim(P_TEXT));
    L_TEXT := REMOVE_ACCENTS(LOWER(Trim(P_TEXT)));
    -- Có thể mở rộng loại bỏ dấu tiếng Việt nếu cần thiết
    Return L_TEXT;
  End;

  -- Hàm parse địa chỉ từ phải sang trái. Nếu cuối cùng là "Việt Nam" thì bỏ qua.
  Procedure PARSE_ADDRESS(P_ADDRESS  Nvarchar2,
                          O_STREET   Out Nvarchar2,
                          O_WARD     Out Nvarchar2,
                          O_DISTRICT Out Nvarchar2,
                          O_PROVINCE Out Nvarchar2) Is
    V_PARTS   Integer;
    V_WORKING Nvarchar2(1000);
    V_COUNTRY Nvarchar2(100);
    V_POS     Integer;
  Begin
    V_WORKING := P_ADDRESS;
    V_COUNTRY := Trim(REGEXP_SUBSTR(V_WORKING, '[^,]+$', 1, 1));
    --DBMS_OUTPUT.PUT_LINE(V_WORKING);
    -- Nếu phần cuối là "Việt Nam" thì loại bỏ
    If NORMALIZE_TEXT(V_COUNTRY) = NORMALIZE_TEXT('việt nam') Then
      -- Xoá cụm ", Việt Nam" ở cuối chuỗi (có thể có dấu cách)
      V_WORKING := REGEXP_REPLACE(V_WORKING, ',\s*Việt Nam$', '', 1, 1, 'i');
    End If;
    V_PARTS    := REGEXP_COUNT(V_WORKING, ',') + 1;
    O_PROVINCE := Trim(REGEXP_SUBSTR(V_WORKING, '[^,]+', 1, V_PARTS));
    O_DISTRICT := Trim(REGEXP_SUBSTR(V_WORKING, '[^,]+', 1, V_PARTS - 1));
    O_WARD     := Trim(REGEXP_SUBSTR(V_WORKING, '[^,]+', 1, V_PARTS - 2));
    O_PROVINCE := REGEXP_SUBSTR(O_PROVINCE,
                                '(Tỉnh\s+|Thành phố\s+|TP\.\s*|TP\s+)?([^\d,]+)',
                                1, 1, 'i', 2);
    O_DISTRICT := REGEXP_SUBSTR(O_DISTRICT,
                                '(Huyện\s+|Quận\s+|Thị xã\s+|Thành phố\s+)?([^,\d]+)',
                                1, 1, 'i', 2);
    O_WARD     := REGEXP_SUBSTR(O_WARD,
                                '(Phường\s+|Xã\s+|Thị trấn\s+|P\.|X\.|TT\.)?\s*([^,]+)',
                                1, 1, 'i', 2);
   

    O_STREET := '';
    For I In 1 .. V_PARTS - 3
    Loop
      If I > 1 Then
        O_STREET := O_STREET || ', ';
      End If;
      O_STREET := O_STREET || Trim(REGEXP_SUBSTR(V_WORKING, '[^,]+', 1, I));
    End Loop;
    --DBMS_OUTPUT.PUT_LINE(O_STREET);
    -- Phần còn lại là o_street (nếu có nhiều hơn 3 dấu phẩy)
    /*    If V_PARTS > 4 Then
      V_POS := INSTR(V_WORKING, O_WARD, 1, 1);
      If V_POS > 1 Then
        O_STREET := RTRIM(SUBSTR(V_WORKING, 1, V_POS - 2), ', ');
      Else
        O_STREET := Null;
      End If;
    Else
      O_STREET := Trim(REGEXP_SUBSTR(V_WORKING, '[^,]+', 1, 1));
    End If;
    DBMS_OUTPUT.PUT_LINE(O_STREET);*/
  End;

  Function FIND_BEST_MAPPING(P_WARD     Nvarchar2,
                             P_DISTRICT Nvarchar2,
                             P_PROVINCE Nvarchar2)
    Return WARD_MAPPINGS%Rowtype Is
    L_MAPPING WARD_MAPPINGS%Rowtype;
  Begin
    -- Exact match ưu tiên
    Begin
      Select *
      Into   L_MAPPING
      From   WARD_MAPPINGS
      Where  NORMALIZE_TEXT(OLD_WARD_NAME) = NORMALIZE_TEXT(P_WARD) And
             NORMALIZE_TEXT(OLD_DISTRICT_NAME) = NORMALIZE_TEXT(P_DISTRICT) And
             NORMALIZE_TEXT(OLD_PROVINCE_NAME) = NORMALIZE_TEXT(P_PROVINCE)
      Fetch  First 1 ROWS Only;
      Return L_MAPPING;
    Exception
      When NO_DATA_FOUND Then
        Null;
    End;
    -- Fuzzy match: dùng LIKE đơn giản (có thể mở rộng dùng UTL_MATCH)
    Begin
      Select *
      Into   L_MAPPING
      From   WARD_MAPPINGS A
      Where  ADDRESS_CONVERTER.NORMALIZE_TEXT(A.OLD_WARD_NAME) Like
             '%' || ADDRESS_CONVERTER.NORMALIZE_TEXT(P_WARD) || '%' And
             ADDRESS_CONVERTER.NORMALIZE_TEXT(A.OLD_DISTRICT_NAME) Like
             '%' || ADDRESS_CONVERTER.NORMALIZE_TEXT(P_DISTRICT) || '%' And
             ADDRESS_CONVERTER.NORMALIZE_TEXT(A.OLD_PROVINCE_NAME) Like
             '%' || ADDRESS_CONVERTER.NORMALIZE_TEXT(P_PROVINCE) || '%'
      Fetch  First 1 ROWS Only;
      Return L_MAPPING;
    Exception
      When NO_DATA_FOUND Then
        Return Null;
    End;
  End;

  Function CONVERT_ADDRESS(P_ADDRESS In Nvarchar2) Return T_RESULT Is
    L_STREET      Nvarchar2(255);
    L_WARD        Nvarchar2(255);
    L_DISTRICT    Nvarchar2(255);
    L_PROVINCE    Nvarchar2(255);
    L_MAPPING     WARD_MAPPINGS%Rowtype;
    L_SUCCESS     Number(1) := 0;
    L_MESSAGE     Nvarchar2(200) := 'Không tìm thấy mapping phù hợp';
    L_NEW_ADDRESS Nvarchar2(500);
    L_HAS_VIETNAM Number(1) := 0;
    L_VN_SUFFIX   Nvarchar2(20) := ', Việt Nam';
  Begin
    -- Kiểm tra có "Việt Nam" ở cuối không (không phân biệt hoa thường)
    If REGEXP_LIKE(Trim(P_ADDRESS), ',\s*Việt\s*Nam\s*$', 'i') Then
      L_HAS_VIETNAM := 1;
    End If;
    -- Parse Địa chỉ (bỏ "Việt Nam" nếu có)
    PARSE_ADDRESS(P_ADDRESS, L_STREET, L_WARD, L_DISTRICT, L_PROVINCE);
    If L_PROVINCE Is Null Then
      Return T_RESULT(0, P_ADDRESS, Null, 'Địa chỉ phải có tỉnh/thành phố');
    End If;
    -- Tìm mapping tối ưu
    L_MAPPING := FIND_BEST_MAPPING(L_WARD, L_DISTRICT, L_PROVINCE);
    If L_MAPPING.ID Is Not Null Then
      L_SUCCESS := 1;
      L_MESSAGE := 'Chuyển đổi thành công';
      -- Xây địa chỉ mới theo mapping
      L_NEW_ADDRESS := NVL(Trim(L_STREET), '') || Case
                         When L_STREET Is Not Null Then
                          ', '
                         Else
                          ''
                       End || NVL(Trim(L_MAPPING.NEW_WARD_NAME), '') || Case
                         When L_MAPPING.NEW_WARD_NAME Is Not Null Then
                          ', '
                         Else
                          ''
                       End || NVL(Trim(L_MAPPING.NEW_PROVINCE_NAME), '');
      -- Nếu địa chỉ gốc có "Việt Nam", thêm vào cuối
      If L_HAS_VIETNAM = 1 Then
        L_NEW_ADDRESS := L_NEW_ADDRESS || L_VN_SUFFIX;
      End If;
    Else
      L_NEW_ADDRESS := Null;
    End If;
    Return T_RESULT(L_SUCCESS, P_ADDRESS, L_NEW_ADDRESS, L_MESSAGE);
  End;

  -- hàm này chậm kinh khủng
  Function REMOVE_ACCENTS(P_STRING In Varchar2) Return Varchar2 Is
    V_RESULT Varchar2(4000);
  Begin
    V_RESULT := TRANSLATE(P_STRING,
                          'ăâđêôơưàảãạáằẳẵặắầẩẫậấèẻẽẹéềểễệếìỉĩịíòỏõọóồổỗộốờởỡợớùủũụúừửữựứỳỷỹỵýĂÂĐÊÔƠƯÀẢÃẠÁẰẲẴẶẮẦẨẪẬẤÈẺẼẸÉỀỂỄỆẾÌỈĨỊÍÒỎÕỌÓỒỔỖỘỐỜỞỠỢỚÙỦŨỤÚỪỬỮỰỨỲỶỸỴÝ',
                          'aadeoouaaaaaaaaaaaaaaaeeeeeeeeeeiiiiiooooooooooooooouuuuuuuuuuyyyyyAADEOOUAAAAAAAAAAAAAAAEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOUUUUUUUUUUYYYYYDD'); -- Loại bỏ ký tự không phải chữ hoặc số
    V_RESULT := REGEXP_REPLACE(V_RESULT, '[^a-z0-9]', '');
    Return V_RESULT;
  End;

End ADDRESS_CONVERTER;
