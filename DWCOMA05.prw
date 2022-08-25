#INCLUDE "Protheus.ch"

User Function DWCOMA05()

	Local oReport := Nil
	Private cTab := GetNextAlias()
	
	oReport := ReportDef()
	oReport:PrintDialog()

Return()

Static Function ReportDef()

	Local oReport   := Nil
	Local oSect1 := Nil
	Local oSect2 := Nil

	oReport := TReport():New("DWCOMA05", "Lista de Pedidos","DWCOMA05", {|oReport| ReportPrint(oReport)}, "Imprime lista de pedidos.")

	oReport:SetPortrait()

	oSect1 := TRSection():New(oReport)
	TRCell():New(oSect1, "C5_NUM"   , , "Codigo"   , , TamSX3("C5_NUM")[1] , , {|| (cTab)->C5_NUM}) //Criar as colunas que vão aparecer no relatório
	TRCell():New(oSect1, "C5_TIPO"   , , "Tipo"   , , TamSX3("C5_TIPO")[1] , , {|| (cTab)->C5_TIPO})
	TRCell():New(oSect1, "C5_CLIENTE" , , "Cliente" , , TamSX3("C5_CLIENTE")[1]  , ,{|| (cTab)->C5_CLIENTE} )
	TRCell():New(oSect1, "C5_LOJACLI" , ,"Loja"   , , TamSX3("C5_LOJACLI")[1]   , ,{|| (cTab)->C5_LOJACLI} )
	TRCell():New(oSect1, "C5_TIPOCLI"   , , "Tipo Cliente"   , , TamSX3("C5_TIPOCLI")[1] , ,{|| (cTab)->C5_TIPOCLI})
	TRCell():New(oSect1, "C5_CONDPAG"	, , "Cond. Pgto", , TamSX3("C5_CONDPAG")[1] , , {|| (cTab)->C5_CONDPAG} )

	oBreak1 := TRBreak():New(oSect1, {|| (cTab)->C5_NUM}, )
	TRFunction():New(oSect1:Cell("C5_NUM"), , "Codigo", oBreak1, , ,, .F. , .F., .F., , , , )
	TRFunction():New(oSect1:Cell("C5_TIPO") , , "Tipo", oBreak1, , PesqPict("SC5", "C5_TIPO"),  , .F., .F., .F.)
	TRFunction():New(oSect1:Cell("C5_CLIENTE") , , "Cliente", oBreak1, /**/, PesqPict("SC5", "C5_CLIENTE"),  , .F., .F., .F./*lEndPage*/)
	TRFunction():New(oSect1:Cell("C5_LOJACLI") , , "Loja", oBreak1, /**/, PesqPict("SC5", "C5_LOJACLI"), , .F., .F., .F./*lEndPage*/)
	TRFunction():New(oSect1:Cell("C5_TIPOCLI") , , "Tipo Cliente", oBreak1, /**/, PesqPict("SC5", "C5_TIPOCLI"),, .F., .F., .F./*lEndPage*/)
	TRFunction():New(oSect1:Cell("C5_CONDPAG") , , "SUM", oBreak1, /**/, PesqPict("SC5", "C5_CONDPAG"),   , .F., .F., .F./*lEndPage*/)


	oSect2 := TRSection():New(oReport)
	TRCell():New(oSect2, "C6_ITEM", , "Item"	, , TamSX3("C6_ITEM")[1]   , ,{|| (cTab)->C6_ITEM})
	TRCell():New(oSect2, "C6_PRODUTO"	, , "Produto"	, , TamSX3("C6_PRODUTO")[1]   , , {|| (cTab)->C6_PRODUTO})
	TRCell():New(oSect2, "C6_QTDVEN", , "Quantidade"	, , TamSX3("C6_QTDVEN")[1]   , ,{|| (cTab)->C6_QTDVEN})
	TRCell():New(oSect2, "C6_PRCVEN"	, , "Valor"	, , TamSX3("C6_PRCVEN")[1]+12   , /*lPixel*/,{|| (cTab)->C6_PRCVEN})
	TRCell():New(oSect2, "C6_TES", , "TES"	, , TamSX3("C6_TES")[1]   , /*lPixel*/,{|| (cTab)->C6_TES})

Return(oReport)

Static Function ReportPrint(oReport)
	Local oSect1 := Nil
	Local oSect2 := Nil
	Local nRegs     := 0
	Local nCont     := 0
	Local cQuery := ""

	Default oReport := Nil
	cQuery += "SELECT C5_NUM,"		+ CRLF
	cQuery += "C5_TIPO,"			+ CRLF
	cQuery += "C5_CLIENTE,"			+ CRLF //+
	cQuery += "C5_LOJACLI,"	+ CRLF
	cQuery += "C5_TIPOCLI," 	+ CRLF
	cQuery += "C5_CONDPAG, "	+ CRLF
	cQuery += "C6_ITEM,  " 	+ CRLF
	cQuery += "C6_PRODUTO,"	+ CRLF
	cQuery += "C6_QTDVEN, "	+ CRLF
	cQuery += "C6_PRCVEN,"	 + CRLF
	cQuery += "C6_TES FROM "+ RetSQLName("SC5") +" INNER JOIN "+ RetSQLName("SC6")+" ON SC5990.C5_NUM = SC6990.C6_NUM"+ CRLF
	cQuery += "ORDER BY C5_NUM"+ CRLF

	MPSysOpenQuery(cQuery, cTab)

	DbSelectArea((cTab))
	Count To nRegs
	(cTab)->(DbGoTop())

	If (!Empty(nRegs))
		oReport:SetMeter(nRegs)

		cNat := (cTab)->C5_NUM

		oSect1 := oReport:Section(1)
		oSect2 := oReport:Section(2)

		oSect1:Init()
		oSect2:Init()

		oSect1:PrintLine()
	Endif

	While ((cTab)->(!Eof()))
		nCont++
		oReport:IncMeter()

		oSect1:PrintLine()

		If (cNat <> (cTab)->C5_NUM)
			oSect1:Finish()

			cNat := (cTab)->C5_NUM

			oSect1:Init()

			oSect1:PrintLine()
		Endif

		oSect2:PrintLine()


		If (nCont == nRegs)
			oSect1:Finish()
			oSect2:Finish()

			oReport:EndPage()
		Endif

		(cTab)->(DbSkip())
	Enddo

	(cTab)->(DbCloseArea())
Return()
