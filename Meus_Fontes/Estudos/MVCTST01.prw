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

	oBrowseSZ1:SetDescription("Pr? Pedido vendas - MVC")

	oBrowseSZ1:Activate()


Return()


Static Function MenuDef() /*Uma fun??o MenuDef define as opera??es quer ser?o realizadas pela aplica??o, tais como inclus?o,
	altera??o, exclus?o, etc.*/
	Local aRotina := {}

	Add Option aRotina Title OemToAnsi("Visualizar") Action "VIEWDEF.MVCOMA01" Operation 2 Access 0
	Add Option aRotina Title OemToAnsi("Incluir")    Action "VIEWDEF.MVCOMA01" Operation 3 Access 0
	Add Option aRotina Title OemToAnsi("Alterar")    Action "VIEWDEF.MVCOMA01" Operation 4 Access 0
	Add Option aRotina Title OemToAnsi("Excluir")    Action "VIEWDEF.MVCOMA01" Operation 5 Access 0
	Add Option aRotina Title OemToAnsi("Incuir Ped. Venda") Action "u_Import" Operation 4 Access 0
	Add Option aRotina Title OemToAnsi("Estornar Ped. Venda") Action "u_Estornar" Operation 4 Access 0

Return aRotina



Static Function ModelDef() //Fun?ao modelo
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
	oModel:SetDescription(OemToAnsi("Modelo de dados do Pr? pedido de venda"))
	oModel:GetModel("SZ1MASTER"):SetDescription(OemToAnsi("Cabecalho Pr? pedido de venda"))
	oModel:GetModel("SZ2DETAIL"):SetDescription(OemToAnsi("Linha Pr? pedido de venda"))

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
	oView:CreateHorizontalBox("TELA01",50)
	oView:CreateHorizontalBox("TELA02",50)
	oView:SetOwnerView("FIELD_SZ1", "TELA01")
	oView:SetOwnerView("GRID_SZ2", "TELA02")
	oView:AddIncrementField("GRID_SZ2", "Z2_ITEM")


Return (oView)


User Function Import()
	Local cVar := ""
	Private lMsErroAuto := .F.
	aCabec   := {}
	aItens   := {}
	aLinha   := {}

	DbSelectArea("SZ2")
	SZ2->(DbSetOrder(1))
	SZ2->(DbSeek(xFilial("SZ2")+(SZ1->Z1_CODIGO)))

	If	(SZ1->Z1_CODIGO) == (SC5->C5_CODPP) // Se o codigo for o mesmo do codigo do pedido j? estara incluido 
		MsgInfo("Pedido de Venda j? incluso.", "Aviso")
	else

	cVar := GetSXENum("SC5", "C5_NUM")

		aCabec   := {}
		aItens   := {}
		aLinha   := {}
		aadd(aCabec, {"C5_NUM"	,			cVar						, Nil})
		aadd(aCabec, {"C5_TIPO", 			(SZ1->Z1_TIPOPED)	, Nil})
		aadd(aCabec, {"C5_CLIENTE",		(SZ1->Z1_CLIENTE)	, Nil})
		aadd(aCabec, {"C5_LOJACLI", 	(SZ1->Z1_LOJACLI)	, Nil})
		aadd(aCabec, {"C5_CONDPAG", 	(SZ1->Z1_CONDPAG)	, Nil})

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
		nOpcX := 3

		MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)

		If (lMsErroAuto)
			MostraErro()
			RollbackSx8()
		Else
			ConfirmSx8()
			RecLock("SZ1", .F.)
			SZ1->Z1_NUMERO := cVar
			SZ1->(MsUnlock())

			RecLock("SC5", .F.)
			SC5->C5_CODPP := SZ1->Z1_CODIGO
			SC5->(MsUnlock())

			MsgInfo("Pedido de Venda incluido com sucesso.", "Aviso")
		Endif
	Endif
Return()



User Function Estornar()

	Private lMsErroAuto := .F.
	aCabec   := {}
	aItens   := {}
	aLinha   := {}

	DbSelectArea("SZ2")
	SZ2->(DbSetOrder(1))
	SZ2->(DbSeek(xFilial("SZ2")+(SZ1->Z1_CODIGO)))

	aCabec   := {}
	aItens   := {}
	aLinha   := {}
	aadd(aCabec, {"C5_NUM"	,		(SZ1->Z1_NUMERO)	, Nil})
	aadd(aCabec, {"C5_TIPO", 		(SZ1->Z1_TIPOPED)		, Nil})
	aadd(aCabec, {"C5_CLIENTE",		(SZ1->Z1_CLIENTE)	, Nil})
	aadd(aCabec, {"C5_LOJACLI", 	(SZ1->Z1_LOJACLI)	, Nil})
	aadd(aCabec, {"C5_CONDPAG", 	(SZ1->Z1_CONDPAG)	, Nil})

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

	nOpcX := 5
	MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)
If (lMsErroAuto)
		MostraErro()
	Else
		RecLock("SZ1", .F.)
		SZ1->Z1_NUMERO := "" //apagar campo
		SZ1->(MsUnlock())

		RecLock("SC5", .F.)
		SC5->C5_CODPP := ""
		SC5->(MsUnlock())

		MsgInfo("Pedido de Venda exclu?do com sucesso.", "Aviso")
	Endif
Return()
