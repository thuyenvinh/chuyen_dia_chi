create table TEMP_CONVERT_ADD
(
  id      NUMBER(12) not null,
  old_add VARCHAR2(1000),
  new_add VARCHAR2(1000),
  MESSAGE VARCHAR2(100)
);

insert into TEMP_CONVERT_ADD xxxx;


Begin
  For REC In (Select ID, OLD_ADD
              From   TEMP_CONVERT_ADD A
              Where  A.NEW_ADD Is Null)
  Loop
    Declare
      V_RESULT ADDRESS_CONVERTER.T_RESULT;
    Begin
      V_RESULT := ADDRESS_CONVERTER.CONVERT_ADDRESS(REC.OLD_ADD);
      Update TEMP_CONVERT_ADD
      Set    NEW_ADD = V_RESULT.CONVERTED_ADDRESS,
             MESSAGE = V_RESULT.MESSAGE
      Where  ID = REC.ID;
    End;
  End Loop;
End;