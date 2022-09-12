#Include "Protheus.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} MVCOMA01
Pedido de Venda
@type function
@author Gabriel Marques
@since 11/06/2021
/*/

User Function MVCOMA01()
	Local aArea := GetNextAlias()
	Local oBrowseSZ1
	//Local oBrowseSZ2

	oBrowseSZ1 := FwmBrowse():New()
	//oBrowseSZ2 := FwmBrowse():New()
	//Passo como parametro a tabala que eu quero mostrar no browse
	oBrowseSZ1:SetAlias("SZ1")

	oBrowseSZ1:SetDescription("Pré Pedido vendas - MVC")

	oBrowseSZ1:Activate()

	RestArea(aArea)

Return()


Static Function MenuDef() /*Uma função MenuDef define as operações quer serão realizadas pela aplicação, tais como inclusão,
	alteração, exclusão, etc.*/
	Local aRotina := {}

	Add Option aRotina Title OemToAnsi("Visualizar") Action "VIEWDEF.MVCOMA01" Operation 2 Access 0
	Add Option aRotina Title OemToAnsi("Incluir")    Action "VIEWDEF.MVCOMA01" Operation 3 Access 0
	Add Option aRotina Title OemToAnsi("Alterar")    Action "VIEWDEF.MVCOMA01" Operation 4 Access 0
	Add Option aRotina Title OemToAnsi("Excluir")    Action "VIEWDEF.MVCOMA01" Operation 5 Access 0
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

	oModel:SetRelation("SZ2DETAIL", {{"Z2_FILIAL", "xFilial('SZ2')"}, {"Z2_ITEM", "Z2_PRODUTO"}}, SZ2->(IndexKey(1)))

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
	oSZ2 := FWFormStruct(2, "SZ2")

	oView:SetModel(oModel)
	oView:AddField("FIELD_SZ1", oSZ1, "SZ1MASTER")
	oView:AddGrid("GRID_SZ2", oSZ2, "SZ2DETAIL")
	oView:CreateHorizontalBox("TELA01",20)
	oView:CreateHorizontalBox("TELA02",80)
	oView:SetOwnerView("FIELD_SZ1", "TELA01")
	oView:SetOwnerView("GRID_SZ2", "TELA02")
	oView:AddIncrementField("GRID_SZ2", "Z2_ITEM")


Return (oView)
