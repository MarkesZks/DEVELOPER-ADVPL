#Include "Protheus.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} MVCOMA01
Pedido de Venda
@type function
@author Gabriel Marques
@since 11/06/2021
/*/

User Function MVCOMA01()
	Local oBrowseSZ1 := Nil
	//Local oBrowseSZ2
	oBrowseSZ1 := FwmBrowse():New()
	//oBrowseSZ2 := FwmBrowse():New()
	//Passo como parametro a tabala que eu quero mostrar no browse
	oBrowseSZ1:SetAlias("SZ1")

	oBrowseSZ1:SetDescription("Pré Pedido vendas - MVC")

	oBrowseSZ1:Activate()


Return()


Static Function MenuDef() /*Uma função MenuDef define as operações quer serão realizadas pela aplicação, tais como inclusão,
	alteração, exclusão, etc.*/
	Local aRotina := {}

	Add Option aRotina Title OemToAnsi("Visualizar") Action "VIEWDEF.MVCOMA01" Operation 2 Access 0
	Add Option aRotina Title OemToAnsi("Incluir")    Action "VIEWDEF.MVCOMA01" Operation 3 Access 0
	Add Option aRotina Title OemToAnsi("Alterar")    Action "VIEWDEF.MVCOMA01" Operation 4 Access 0
	Add Option aRotina Title OemToAnsi("Excluir")    Action "VIEWDEF.MVCOMA01" Operation 5 Access 0
	Add Option aRotina Title OemToAnsi("Incuir Ped. Venda") Action "u_Import" Operation 4 Access 0
	Add Option aRotina Title OemToAnsi("Estornar Ped. Venda") Action "u_Estornar" Operation 4 Access 0

Return aRotina



Static Function ModelDef() //Funçao modelo
	Local oModel := Nil //Objeto modelo
	Local oSZ1 := Nil
	Local oSZ2 := Nil

	oSZ1 := FWFormStruct(1, "SZ1")
	oSZ2 := FWFormStruct(1, "SZ2")

	oModel := MPFormModel():New("COMA01PV", /*bPre*/, /*bPost*/, )

	oModel:AddFields("SZ1MASTER",,oSZ1)
	oModel:AddGrid("SZ2DETAIL", "SZ1MASTER", oSZ2)
	oModel:SetPrimaryKey({'Z1_FILIAL','Z1_CODIGO'})
	oModel:GetModel("SZ2DETAIL"):SetUniqueLine({"Z2_PRODUTO"})
	oModel:SetRelation("SZ2DETAIL", {{"Z2_FILIAL", "xFilial('SZ1')"}, {"Z2_CODIGO", "Z1_CODIGO"}}, SZ2->(IndexKey(1)))
	oModel:SetDescription(OemToAnsi("Modelo de dados do Pré pedido de venda"))
	oModel:GetModel("SZ1MASTER"):SetDescription(OemToAnsi("Cabecalho Pré pedido de venda"))
	oModel:GetModel("SZ2DETAIL"):SetDescription(OemToAnsi("Linha Pré pedido de venda"))

Return (oModel)



Static Function ViewDef()

	Local oModel := Nil
	Local oView := Nil
	Local oSZ1 := Nil
	Local oSZ2 := Nil


	oModel := ModelDef()
	oView := FWFormView():New()
	oSZ1 := FWFormStruct(2, "SZ1")
	oSZ2 := FWFormStruct(2, "SZ2",{|x| !(AllTrim(x) $ "Z2_FILIAL|Z2_CODIGO|")})

	oView:SetModel(oModel)
	oView:AddField("FIELD_SZ1", oSZ1, "SZ1MASTER")
	oView:AddGrid("GRID_SZ2", oSZ2, "SZ2DETAIL")
	oView:CreateHorizontalBox("TELA01",20)
	oView:CreateHorizontalBox("TELA02",80)
	oView:SetOwnerView("FIELD_SZ1", "TELA01")
	oView:SetOwnerView("GRID_SZ2", "TELA02")
	oView:AddIncrementField("GRID_SZ2", "Z2_ITEM")


Return (oView)



User Function Import()
	Local cQuery := ""
	Private lMsErroAuto := .F.
	aCabec   := {}
	aItens   := {}
	aLinha   := {}
	//SC6 :=Nil
	//SC5 :=Nil


	cQuery := "SELECT Z2_ITEM"+ CRLF
	cQuery += ",Z2_PRODUTO" + CRLF
	cQuery += ",Z2_QTDVEN" + CRLF
	cQuery += ",Z2_PRECO" + CRLF
	cQuery += ",Z2_CODIGO" + CRLF
	cQuery += ",Z2_TES FROM " + RetSQLName("SZ2") + CRLF
	cQuery += "WHERE D_E_L_E_T_= ''"+ CRLF


	DbSelectArea("SZ2")
	SZ2->(DbSetOrder(1))
	SZ2->(DbSeek(xFilial("SZ2")+(SZ1->Z1_CODIGO)))

	aCabec   := {}
	aItens   := {}
	aLinha   := {}
	aadd(aCabec, {"C5_NUM"	,		GetSXENum("SC5", "C5_NUM")	, Nil})
	aadd(aCabec, {"C5_TIPO", 		(SZ1->Z1_TIPOPED)	, Nil})
	aadd(aCabec, {"C5_CLIENTE",		(SZ1->Z1_CLIENTE)	, Nil})
	aadd(aCabec, {"C5_LOJACLI", 	(SZ1->Z1_LOJACLI)	, Nil})
	aadd(aCabec, {"C5_CONDPAG", 	(SZ1->Z1_CONDPAG)	, Nil})
	//aadd(aCabec, {"C5_TIPOCLI",		(SZ1->Z1_TIPOCLI)	, Nil})

	while (SZ1->(xFilial("SZ1")+(SZ1->Z1_CODIGO))) == SZ2->(xFilial("SZ2")+SZ2->Z2_CODIGO) .and. SZ2->(!EOF())

		aLinha := {}
		aadd(aLinha,{"C6_ITEM",			(SZ2->Z2_ITEM)    , Nil})
		aadd(aLinha,{"C6_PRODUTO", 		(SZ2->Z2_PRODUTO) , Nil})
		aadd(aLinha,{"C6_QTDVEN", 		(SZ2->Z2_QTDVEN)  , Nil})
		aadd(aLinha,{"C6_PRCVEN",  		(SZ2->Z2_PRCVEN)	  , Nil})
		aadd(aLinha,{"C6_TES",			(SZ2->Z2_TES)	  , Nil})
		aadd(aItens, aLinha)

		DBSkip()

	ENDDO
	SZ1->Z1_NUMERO := SC5->C5_NUM


	nOpcX := 3
	MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)

	If (lMsErroAuto)
		MostraErro()
	Else
		MsgInfo("Pedido de Venda incluido com sucesso.", "Aviso")
	Endif
Return()




User Function Estornar()
	Local cQuery := ""
	Private lMsErroAuto := .F.
	aCabec   := {}
	aItens   := {}
	aLinha   := {}

	cQuery := "SELECT Z2_ITEM"+ CRLF
	cQuery += ",Z2_PRODUTO" + CRLF
	cQuery += ",Z2_QTDVEN" + CRLF
	cQuery += ",Z2_PRECO" + CRLF
	cQuery += ",Z2_CODIGO" + CRLF
	cQuery += ",Z2_TES FROM " + RetSQLName("SZ2") + CRLF
	cQuery += "WHERE D_E_L_E_T_= ''"+ CRLF


	DbSelectArea("SZ2")
	SZ2->(DbSetOrder(1))
	SZ2->(DbSeek(xFilial("SZ2")+(SZ1->Z1_CODIGO)))

	
	aCabec   := {}
	aItens   := {}
	aLinha   := {}
	aadd(aCabec, {"C5_NUM"	,		(SZ1->Z1_NUMERO)	, Nil})
	aadd(aCabec, {"C5_TIPO", 		(SZ1->Z1_TIPOPED)	, Nil})
	aadd(aCabec, {"C5_CLIENTE",		(SZ1->Z1_CLIENTE)	, Nil})
	aadd(aCabec, {"C5_LOJACLI", 	(SZ1->Z1_LOJACLI)	, Nil})
	aadd(aCabec, {"C5_CONDPAG", 	(SZ1->Z1_CONDPAG)	, Nil})
	//aadd(aCabec, {"C5_TIPOCLI",		(SZ1->Z1_TIPOCLI)	, Nil})

	while (SZ1->(xFilial("SZ1")+(SZ1->Z1_CODIGO))) == SZ2->(xFilial("SZ2")+SZ2->Z2_CODIGO) .and. SZ2->(!EOF())

		aLinha := {}
		aadd(aLinha,{"C6_ITEM",			(SZ2->Z2_ITEM)    , Nil})
		aadd(aLinha,{"C6_PRODUTO", 		(SZ2->Z2_PRODUTO) , Nil})
		aadd(aLinha,{"C6_QTDVEN", 		(SZ2->Z2_QTDVEN)  , Nil})
		aadd(aLinha,{"C6_PRCVEN",  		(SZ2->Z2_PRCVEN)	  , Nil})
		aadd(aLinha,{"C6_TES",			(SZ2->Z2_TES)	  , Nil})
		aadd(aItens, aLinha)

		DBSkip()

	ENDDO



If (SZ1->(xFilial("SZ1")+(SZ1->Z1_NUMERO))) == SC5->(xFilial("SC5")+(SC5->C5_NUM))

	nOpcX := 5
	MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)
Endif
	If (lMsErroAuto)
		MostraErro()
	Else
		MsgInfo("Pedido de Venda estornado com sucesso.", "Aviso")
	Endif
Return()
