//Relatorio de Fornecedores 
#INCLUDE "Protheus.ch"

User Function DWCOMA06()

	Local oReport := Nil
	Private cTab := GetNextAlias()
	oReport := ReportDef(cTab)
	oReport:PrintDialog()
Return()

Static Function ReportDef(cTab)

	Local oReport   := Nil
	Local oSection1 := Nil
	Local oSection2 := Nil

	oReport := TReport():New("DWCOMA06", "Lista de Pedidos","DWCOMA05", {|oReport| ReportPrint(oReport)}, "Imprime lista de pedidos.")
	oReport:SetPortrait()

	oSection1 := TRSection():New(oReport)
	TRCell():New(oSection1, "C5_NUM"   , , "Codigo"   , /*cPicture*/, TamSX3("C5_NUM")[1]   , /*lPixel*/, {||(cTab) ->C5_NUM}) //Criar as colunas que vão aparecer no relatório
	TRCell():New(oSection1, "C5_TIPO"   , , "Tipo"   , /*cPicture*/, TamSX3("C5_TIPO")[1]   , /*lPixel*/)
	TRCell():New(oSection1, "C5_CLIENTE"   , , "Cliente"   , /*cPicture*/, TamSX3("C5_CLIENTE")[1]   , /*lPixel*/, {||(cTab) ->C5_CLIENTE})
	TRCell():New(oSection1, "C5_LOJACLI" , ,"Loja"   , /*cPictur*/, TamSX3("C5_LOJACLI")[1]   , /*lPixel*/)
	TRCell():New(oSection1, "C5_TIPOCLI"   , , "Tipo Cliente"   , /*cPicture*/, TamSX3("C5_TIPOCLI")[1]   , /*lPixel*/)
	TRCell():New(oSection1, "C5_CONDPAG"	, , "Cond. Pgto"	, /*cPicture*/, TamSX3("C5_CONDPAG")[1]   , /*lPixel*/)

	oBreak1 := TRBreak():New(oSection1, {|| cNat}, )
	TRFunction():New(oSection1:Cell("C5_NUM"), /*cID*/, "Codigo", oBreak1, /**/, /*cPicture*/, {|| cTxt1 + cNat}, .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/, /*oParent*/, /*bCondition*/, /*lDisable*/, /*bCanPrint*/)
	TRFunction():New(oSection1:Cell("C5_TIPO") , /*cID*/, "Tipo", oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), /*uFormula*/ , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection1:Cell("C5_CLIENTE") , /*cID*/, "Cliente", oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), /*uFormula*/ , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection1:Cell("C5_LOJACLI") , /*cID*/, "Loja", oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), /*uFormula*/ , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection1:Cell("C5_TIPOCLI") , /*cID*/, "Tipo Cliente", oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), /*uFormula*/  , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection1:Cell("C5_CONDPAG") , /*cID*/, "SUM", oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), /*uFormula*/  , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	

	oSection2 := TRSection():New(oReport)
	TRCell():New(oSection2, "C6_ITEM", , "Item"	, /*cPicture*/, TamSX3("C6_ITEM")[1]   , /*lPixel*/)
	TRCell():New(oSection2, "C6_PRODUTO"	, , "Produto"	, /*cPicture*/, TamSX3("C6_PRODUTO")[1]   , /*lPixel*/)
	TRCell():New(oSection2, "C6_QTDVEN", , "Quantidade"	, /*cPicture*/, TamSX3("C6_QTDVEN")[1]   , /*lPixel*/)
	TRCell():New(oSection2, "C6_PRCVEN"	, , "Valor"	, /*cPicture*/, TamSX3("C6_PRCVEN")[1]+12   , /*lPixel*/)
	TRCell():New(oSection2, "C6_TES", , "TES"	, /*cPicture*/, TamSX3("C6_TES")[1]   , /*lPixel*/)

Return(oReport)

Static Function ReportPrint(oReport, cTab)
	Local oSection1 := Nil
	Local oSection2 := Nil
	Local nRegs     := 0
	Local nCont     := 0
	Local cQuery := ""

	Default oReport := Nil
	cQuery += "SELECT C5_NUM"+ CRLF
	cQuery += "	,C5_TIPO"    + CRLF
	cQuery += "	,C5_LOJACLI" + CRLF
	cQuery += "	,C5_TIPOCLI" + CRLF
	cQuery += "	,C5_CONDPAG" + CRLF
	cQuery += "	,C6_ITEM"   + CRLF
	cQuery += "	,C6_PRODUTO"+ CRLF
	cQuery += "	,C6_QTDVEN"  + CRLF
	cQuery += "	,C6_PRCVEN"  + CRLF
	cQuery += "	,C6_TES FROM" + RetSQLName("CS5") + " INNER JOIN SC69"+ RetSQLName("CS6") + "ON (SC5990.C5_NUM <> SC6990.C6_PRODUTO);" + CRLF
	MPSysOpenQuery(cQuery, (cTab))
	DbSelectArea(cTab)

	Count To nRegs
	(cTab)->(DbGoTop())

	If (!Empty(nRegs))
		oReport:SetMeter(nRegs)

		cNat := (cTab)->CT1_XNAT

		oSection1 := oReport:Section(1)
		oSection2 := oReport:Section(2)

		oSection1:Init()
		oSection2:Init()

		oSection1:PrintLine()
	Endif

	While ((cTab)->(!Eof()))
		nCont++
		oReport:IncMeter()

		If (cNat <> (cTab)->CT1_XNAT)
			oSection1:Finish()

			cNat := (cTab)->CT1_XNAT

			oSection1:Init()

			oSection1:PrintLine()
		Endif

		oSection2:PrintLine()


		If (nCont == nRegs)
			oSection1:Finish()
			oSection2:Finish()

			oReport:EndPage()
		Endif

		(cTab)->(DbSkip())
	Enddo

	(cTab)->(DbCloseArea())
Return(lRet)
