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
	Add Option aRotina Title OemToAnsi("Estornar Ped. Venda") Action "VIEWDEF.MVCOMA01" Operation 4 Access 0

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
	Private lMsErroAuto := .F.
	aCabec   := {}
	aItens   := {}
	aLinha   := {}
	aadd(aCabec, {"C5_NUM","Z1_CODIGO", Nil})
	aadd(aCabec, {"C5_TIPOCLI","Z1_TIPO",       Nil})
	aadd(aCabec, {"C5_CLIENTE","Z1_CLIENTE",    Nil})
	aadd(aCabec, {"C5_LOJACLI", "Z1_LOJACLI",   Nil})
	aadd(aCabec, {"C5_TIPO", "Z1_TIPOPED",   Nil})
	aadd(aCabec, {"C5_CONDPAG", "Z1_CONDPAG", Nil})
	aLinha := {}
	aadd(aLinha,{"C6_ITEM","Z2_ITEM", Nil})
	aadd(aLinha,{"C6_PRODUTO", "Z2_PRODUTO",Nil})
	aadd(aLinha,{"C6_QTDVEN", "Z2_QTDVEN", Nil})
	aadd(aLinha,{"C6_PRCVEN",  "Z2_PRECO", Nil})
	aadd(aLinha,{"C6_TES","Z2_TES", Nil})
	aadd(aItens, aLinha)

	nOpcX := 3
	MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)

	If (lMsErroAuto)
		MsgInfo("Erro na Importação", "Aviso")
	Else
		ConfirmSx8()
		MsgInfo("Importado com Sucesso", "Aviso")
	Endif
Return()
