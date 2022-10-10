#Include "Protheus.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} DGFINA01
Tela de Log de Transações
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function DGFINA01()
	Local oBrowse := Nil

	oBrowse := BrowseDef()
	oBrowse:Activate()
Return()

/*/{Protheus.doc} BrowseDef
Tela de Log de Transações
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

Static Function BrowseDef()
	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(OemToAnsi("Log de Transações"))
	oBrowse:SetAlias("SZ1")
	oBrowse:AddLegend("Z1_STATUS == '1'", "BR_BRANCO"  , "Importado")
	oBrowse:AddLegend("Z1_STATUS == '2'", "BR_VERMELHO", "Falha na Integração")
	oBrowse:AddLegend("Z1_STATUS == '3'", "BR_AZUL"    , "Integrado")
	oBrowse:AddLegend("Z1_STATUS == '4'", "BR_VERDE"   , "Integrado e Baixado")
Return(oBrowse)

/*/{Protheus.doc} MenuDef
Tela de Log de Transações
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

Static Function MenuDef()
	Local aRotina := {}

	Add Option aRotina Title OemToAnsi("Visualizar")   Action "VIEWDEF.DGFINA01" Operation 2 Access 0
	Add Option aRotina Title OemToAnsi("Incluir")      Action "VIEWDEF.DGFINA01" Operation 3 Access 0
	Add Option aRotina Title OemToAnsi("Alterar")      Action "VIEWDEF.DGFINA01" Operation 4 Access 0
	Add Option aRotina Title OemToAnsi("Excluir")      Action "VIEWDEF.DGFINA01" Operation 5 Access 0
	Add Option aRotina Title OemToAnsi("Legendas")     Action "U_FINA01Leg()"    Operation 2 Access 0
	Add Option aRotina Title OemToAnsi("Relatório")    Action "U_DGFINR01()"     Operation 2 Access 0
	Add Option aRotina Title OemToAnsi("Proc. Manual") Action "U_DGFINR01()"     Operation 6 Access 0
Return(aRotina)

/*/{Protheus.doc} ModelDef
Tela de Log de Transações
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

Static Function ModelDef()
	Local oModel := Nil
	Local oSZ1   := Nil

	oSZ1 := FWFormStruct(1, "SZ1")

	oModel := MPFormModel():New("FINA01Log")

	oModel:AddFields("SZ1MASTER", , oSZ1)
	oModel:SetPrimaryKey({"Z1_FILIAL", "Z1_BORDERO", "Z1_PREFIXO", "Z1_NUM", "Z1_PARCELA", "Z1_TIPO", "Z1_FORNECE", "Z1_LOJA"})
	oModel:SetDescription(OemToAnsi("Log de Transações"))
Return(oModel)

/*/{Protheus.doc} ViewDef
Tela de Log de Transações
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

Static Function ViewDef()
	Local oModel := Nil
	Local oView  := Nil
	Local oSZ1   := Nil

	oModel := ModelDef()
	oView  := FWFormView():New()
	oSZ1   := FWFormStruct(2, "SZ1")

	oView:SetModel(oModel)
	oView:AddField("FIELD_SZ1", oSZ1, "SZ1MASTER")
	oView:CreateHorizontalBox("TELA01", 100)
	oView:SetOwnerView("FIELD_SZ1", "TELA01")
Return(oView)

/*/{Protheus.doc} FINA01Leg
Tela de Log de Transações
@type function
@author TOTVS
@since XX/XX/XXXX
/*/

User Function FINA01Leg()
	Local aCores := {}

	aAdd(aCores, {"BR_BRANCO"  , "Importado"})
	aAdd(aCores, {"BR_VERMELHO", "Falha na Integração"})
	aAdd(aCores, {"BR_AZUL"    , "Integrado"})
	aAdd(aCores, {"BR_VERDE"   , "Integrado e Baixado"})

	BrwLegenda("Log de Transações", "Legenda", aCores)
Return()
