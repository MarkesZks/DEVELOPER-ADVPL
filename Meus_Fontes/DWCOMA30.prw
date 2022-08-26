#Include "Protheus.ch"
/*/{Protheus.doc} DWCOMA01
Inclusão de Produtos
@type function
@author DWC
@since 17/08/2022
/*/

//------------INCLUSOR DE CLIENTES AUTOMATICO-------------------
User Function DWCOMA30()
	Local aClientes := {}
	Local cCodCliente := GetSxeNum("SA1","A1_COD")
    Private lMsErroAuto := .F.

aClientes := {{"A1_FILIAL", xFilial("SA1"), Nil},;
		{"A1_COD"   , cCodCliente , Nil},;
		{"A1_LOJA"  , "01" , Nil},;
		{"A1_NOME"  , "Cliente " + cCodCliente , Nil},;
		{"A1_END"    , "Rua do Cliente" , Nil},;
		{"A1_NREDUZ", "Cliente" , Nil},;
        {"A1_TIPO"   , "F" , Nil},;
		{"A1_EST"  , "SP" , Nil},;
		{"A1_MUN"  , "Município do Cliente" , Nil}}
    
    MsExecAuto({|x,y| MATA030(x,y)}, aClientes, 3)

    If (lMsErroAuto)
        MostraErro()

        RollbackSx8()
    Else
        ConfirmSx8()

        MsgInfo("Cliente incluído com sucesso.", "Aviso")
    Endif
Return()
