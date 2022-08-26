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
	TRCell():New(oSect1, "C5_FILIAL"	, , "Filial", , TamSX3("C5_FILIAL")[1] , , {|| (cTab)->C5_FILIAL})
	//Pegando o campo da filial
	TRCell():New(oSect1, "C5_NUM"   , , "Codigo"   , , TamSX3("C5_NUM")[1] , , {|| (cTab)->C5_NUM}) //Criar as colunas que vão aparecer no relatório
	TRCell():New(oSect1, "C5_TIPO"   , , "Tipo"   , , TamSX3("C5_TIPO")[1] , , {|| (cTab)->C5_TIPO})
	TRCell():New(oSect1, "C5_CLIENTE" , , "Cliente" , , TamSX3("C5_CLIENTE")[1]  , ,{|| (cTab)->C5_CLIENTE} )
	TRCell():New(oSect1, "C5_LOJACLI" , ,"Loja"   , , TamSX3("C5_LOJACLI")[1]   , ,{|| (cTab)->C5_LOJACLI} )
	TRCell():New(oSect1, "C5_TIPOCLI"   , , "Tipo Cliente"   , , TamSX3("C5_TIPOCLI")[1] , ,{|| (cTab)->C5_TIPOCLI})
	TRCell():New(oSect1, "C5_CONDPAG"	, , "Cond. Pgto", , TamSX3("C5_CONDPAG")[1] , , {|| (cTab)->C5_CONDPAG})



	oBreak1 := TRBreak():New(oSect1, {|| (cTab)->C5_NUM}, )
	//Cria�ao de mais um break
	oBreak2 := TRBreak():New(oSect1, {|| (cTab)->C5_FILIAL}, )

	oSect2 := TRSection():New(oReport)
	TRCell():New(oSect2, "C6_FILIAL"	, , "Filial_Prod", , TamSX3("C6_FILIAL")[1] , , {|| (cTab)->C6_FILIAL})
	//Pegando o campo da filial
	TRCell():New(oSect2, "C6_ITEM", , "Item"	, , TamSX3("C6_ITEM")[1]   , ,{|| (cTab)->C6_ITEM})
	TRCell():New(oSect2, "C6_PRODUTO"	, , "Produto"	, , TamSX3("C6_PRODUTO")[1]   , , {|| (cTab)->C6_PRODUTO})
	TRCell():New(oSect2, "C6_QTDVEN", , "Quantidade"	, , TamSX3("C6_QTDVEN")[1]   , ,{|| (cTab)->C6_QTDVEN})
	TRCell():New(oSect2, "C6_PRCVEN"	, , "Valor"	, , TamSX3("C6_PRCVEN")[1]+12   , /*lPixel*/,{|| (cTab)->C6_PRCVEN})
	TRCell():New(oSect2, "C6_TES", , "TES"	, , TamSX3("C6_TES")[1]   , /*lPixel*/,{|| (cTab)->C6_TES})

	oBreak3 := TRBreak():New(oSect2, {|| (cTab)->C6_FILIAL}, )
Return(oReport)


Static Function ReportPrint(oReport)

	Local nRegs     := 0
	Local nCont     := 0
	Local cQuery := ""

	Default oReport := Nil
	cQuery += "SELECT C5_FILIAL,"+ CRLF
	cQuery += "C6_FILIAL,"			+ CRLF
	cQuery += "C5_NUM,"			+ CRLF
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
	cQuery +="WHERE C5_LIBEROK = '' AND SC5990.D_E_L_E_T_ = '' AND SC6990.D_E_L_E_T_ = '' AND C5_FILIAL = "+ xFilial("SC5") +"AND C6_FILIAL = "+ xFilial("SC6")+ CRLF
	cQuery += "ORDER BY C5_NUM"+ CRLF



	MPSysOpenQuery(cQuery, cTab)

	DbSelectArea((cTab))
	Count To nRegs
	(cTab)->(DbGoTop())
	If (!Empty(nRegs))
		oReport:SetMeter(nRegs)

		cNat := (cTab)->C5_NUM
		//CFilial :=(cTab)->C5_FILIAL

		oSectionC := oReport:Section(1)
		oSectionIte := oReport:Section(2)

		oSectionC:Init()
		oSectionIte:Init()
		oSectionC:PrintLine()


	Endif

	While ((cTab)->(!Eof()))
		nCont++
		oReport:IncMeter()
		If (cNat <> (cTab)->C5_NUM)
			oSectionC:Finish()
			oSectionIte:Finish()

			cNat := (cTab)->C5_NUM

			oSectionC:Init()
			oSectionIte:Init()
			oSectionC:PrintLine()

			/* elseif (CFilial <> (cTab)->C5_FILIAL)
			oSectionC:Finish()
			oSectionIte:Finish()

			CFilial := (cTab)->C5_FILIAL

			oSectionC:Init()
			oSectionIte:Init()
			oSectionC:PrintLine()*/
		Endif
		oSectionIte:PrintLine()

		If (nCont == nRegs)
			oSectionC:Finish()
			oSectionIte:Finish()
			oReport:EndPage()
		Endif

		(cTab)->(DbSkip())
	Enddo

	(cTab)->(DbCloseArea())
	Return()
