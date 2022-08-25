#Include "Protheus.ch"

/*/{Protheus.doc} ACPCOR23
Relatório de Orçamento de Despesas por Período - Natureza/ Conta
@type function
@author felipe.morais
@since 19/07/2021
/*/

User Function ACPCOR23()
	Local lRet      := .T.
	Local oReport   := Nil
	Local cTab      := GetNextAlias()

	Private cNat    := ""
	Private nVlr01  := 0
	Private nVlr02  := 0
	Private nVlr03  := 0
	Private nVlr04  := 0

	Private nOrc    := 0
	Private nRet    := 0
	Private nSup    := 0
	Private nTransp := 0
	Private nRev    := 0
	Private nReal   := 0

	If (PCOR23Par())
		If (PCOR23Vld())
			oReport := ReportDef(cTab)
			oReport:PrintDialog()
		Endif
	Endif
Return(lRet)

/*/{Protheus.doc} PCOR23Par
Relatório de Orçamento de Despesas por Período - Natureza/ Conta
@type function
@author felipe.morais
@since 19/07/2021
/*/

Static Function PCOR23Par()
	Local lRet   := .T.
	Local aParam := {}
	Local aRet   := {}

	aAdd(aParam, {1, "Data De"     , CriaVar("AKD_DATA", .T.)  , PesqPict("AKD", "AKD_DATA")  , "", ""    , "", 50, .F.})
	aAdd(aParam, {1, "Data Até"    , CriaVar("AKD_DATA", .T.)  , PesqPict("AKD", "AKD_DATA")  , "", ""    , "", 50, .T.})
	aAdd(aParam, {1, "Natureza De" , CriaVar("CT1_XNAT", .T.)  , PesqPict("CT1", "CT1_XNAT")  , "", "Z2A" , "", 80, .F.})
	aAdd(aParam, {1, "Natureza Até", CriaVar("CT1_XNAT", .T.)  , PesqPict("CT1", "CT1_XNAT")  , "", "Z2A" , "", 80, .T.})
	aAdd(aParam, {1, "CO De"       , CriaVar("AKD_CO", .T.)    , PesqPict("AKD", "AKD_CO")    , "", "AK5" , "", 80, .F.})
	aAdd(aParam, {1, "CO Até"      , CriaVar("AKD_CO", .T.)    , PesqPict("AKD", "AKD_CO")    , "", "AK5" , "", 80, .T.})
	aAdd(aParam, {1, "Orçado"      , CriaVar("AKD_TPSALD", .T.), PesqPict("AKD", "AKD_TPSALD"), "", "AL2A", "", 25, .T.})
	aAdd(aParam, {1, "Retificado"  , CriaVar("AKD_TPSALD", .T.), PesqPict("AKD", "AKD_TPSALD"), "", "AL2A", "", 25, .T.})
	aAdd(aParam, {1, "Suplementado", CriaVar("AKD_TPSALD", .T.), PesqPict("AKD", "AKD_TPSALD"), "", "AL2A", "", 25, .T.})
	aAdd(aParam, {1, "Transposto"  , CriaVar("AKD_TPSALD", .T.), PesqPict("AKD", "AKD_TPSALD"), "", "AL2A", "", 25, .T.})
	aAdd(aParam, {1, "Revisado"    , CriaVar("AKD_TPSALD", .T.), PesqPict("AKD", "AKD_TPSALD"), "", "AL2A", "", 25, .T.})
	aAdd(aParam, {1, "Realizado"   , CriaVar("AKD_TPSALD", .T.), PesqPict("AKD", "AKD_TPSALD"), "", "AL2A", "", 25, .T.})

	lRet := ParamBox(aParam, "Parâmetros", @aRet, , , , , , , , , .T.)
Return(lRet)

/*/{Protheus.doc} ReportDef
Relatório de Orçamento de Despesas por Período - Natureza/ Conta
@type function
@author felipe.morais
@since 19/07/2021
/*/

Static Function ReportDef(cTab)
	Local oReport   := Nil
	Local oSection1 := Nil
	Local oSection2 := Nil
	Local oBreak1   := Nil
	Local oBreak2   := Nil
	Local cTxt1     := OemToAnsi("Total de ")
	Local cTxt2     := OemToAnsi("Total de Despesas")

	oReport := TReport():New("ACPCOR23", OemToAnsi("Orçamento de Despesas por Período - Natureza/ Conta"), Nil, {|oReport| ReportPrint(oReport, cTab)}, OemToAnsi("Orçamento de Despesas por Período - Natureza/ Conta"))

	oReport:SetPortrait()
	oReport:SetFile("ACPCOR23")
	oReport:ShowHeader()

	oSection1 := TRSection():New(oReport)
	oSection1:SetLineStyle(.T.)
	TRCell():New(oSection1, "CT1_XNAT", /*cAlias*/, OemToAnsi("Natureza"), /*cPicture*/, 080, /*lPixel*/, {|| cNat})

	oSection2 := TRSection():New(oReport)
	oSection2:SetLineStyle(.F.)
	TRCell():New(oSection2, "AKD_CO", /*cAlias*/, OemToAnsi("Contas Orçamentária"), /*cPicture*/                 , 120, /*lPixel*/, {|| (cTab)->AKD_CO})
	TRCell():New(oSection2, "VLR01" , /*cAlias*/, OemToAnsi("Orçado")             , PesqPict("AKD", "AKD_VALOR1"), 020, /*lPixel*/, {|| nVlr01}        )
	TRCell():New(oSection2, "VLR02" , /*cAlias*/, OemToAnsi("Retificado")         , PesqPict("AKD", "AKD_VALOR1"), 020, /*lPixel*/, {|| nVlr02}        )
	TRCell():New(oSection2, "VLR03" , /*cAlias*/, OemToAnsi("Suplementado")       , PesqPict("AKD", "AKD_VALOR1"), 020, /*lPixel*/, {|| nVlr03}        )
	TRCell():New(oSection2, "VLR04" , /*cAlias*/, OemToAnsi("Transposto")         , PesqPict("AKD", "AKD_VALOR1"), 020, /*lPixel*/, {|| nVlr04}        )
	TRCell():New(oSection2, "VLR05" , /*cAlias*/, OemToAnsi("Revisado")           , PesqPict("AKD", "AKD_VALOR1"), 020, /*lPixel*/, {|| (cTab)->VLR05} )
	TRCell():New(oSection2, "VLR06" , /*cAlias*/, OemToAnsi("Realizado")          , PesqPict("AKD", "AKD_VALOR1"), 020, /*lPixel*/, {|| (cTab)->VLR06} )

	oBreak1 := TRBreak():New(oSection1, {|| cNat}, /*uTitle*/, /*lTotalInLine*/, /*cName*/, /*lPageBreak*/)
	TRFunction():New(oSection2:Cell("AKD_CO"), /*cID*/, "ONPRINT", oBreak1, /**/, /*cPicture*/                 , {|| cTxt1 + cNat}, .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/, /*oParent*/, /*bCondition*/, /*lDisable*/, /*bCanPrint*/)
	TRFunction():New(oSection2:Cell("VLR01") , /*cID*/, "SUM"    , oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), /*uFormula*/     , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLR02") , /*cID*/, "SUM"    , oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), /*uFormula*/     , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLR03") , /*cID*/, "SUM"    , oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), /*uFormula*/     , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLR04") , /*cID*/, "SUM"    , oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), /*uFormula*/     , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLR05") , /*cID*/, "SUM"    , oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), /*uFormula*/     , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLR06") , /*cID*/, "SUM"    , oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), /*uFormula*/     , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)

	oBreak2 := TRBreak():New(oSection2, {|| .F.}, /*uTitle*/, /*lTotalInLine*/, /*cName*/, /*lPageBreak*/)
	TRFunction():New(oSection2:Cell("AKD_CO"), /*cID*/, "ONPRINT", oBreak2, /**/, /*cPicture*/                 , {|| cTxt2}  , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/, /*oParent*/, /*bCondition*/, /*lDisable*/, /*bCanPrint*/)
	TRFunction():New(oSection2:Cell("VLR01") , /*cID*/, "ONPRINT", oBreak2, /**/, PesqPict("AKD", "AKD_VALOR1"), {|| nOrc}   , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLR02") , /*cID*/, "ONPRINT", oBreak2, /**/, PesqPict("AKD", "AKD_VALOR1"), {|| nRet}   , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLR03") , /*cID*/, "ONPRINT", oBreak2, /**/, PesqPict("AKD", "AKD_VALOR1"), {|| nSup}   , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLR04") , /*cID*/, "ONPRINT", oBreak2, /**/, PesqPict("AKD", "AKD_VALOR1"), {|| nTransp}, .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLR05") , /*cID*/, "ONPRINT", oBreak2, /**/, PesqPict("AKD", "AKD_VALOR1"), {|| nRev}   , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection2:Cell("VLR06") , /*cID*/, "ONPRINT", oBreak2, /**/, PesqPict("AKD", "AKD_VALOR1"), {|| nReal}  , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
Return(oReport)

/*/{Protheus.doc} ReportPrint
Relatório de Orçamento de Despesas por Período - Natureza/ Conta
@type function
@author felipe.morais
@since 19/07/2021
/*/

Static Function ReportPrint(oReport, cTab)
	Local lRet      := .T.
	Local oSection1 := Nil
	Local oSection2 := Nil
	Local nRegs     := 0
	Local nCont     := 0
	Local cQuery    := ""

	cQuery := "SELECT CT1_XNAT" + CRLF
	cQuery += "	,AKD_CO" + CRLF
	cQuery += "	,ISNULL([" + AllTrim(mv_par07) + "], 0) AS VLR01" + CRLF
	cQuery += "	,ISNULL([" + AllTrim(mv_par08) + "], 0) AS VLR02" + CRLF
	cQuery += "	,ISNULL([" + AllTrim(mv_par09) + "], 0) AS VLR03" + CRLF
	cQuery += "	,ISNULL([" + AllTrim(mv_par10) + "], 0) AS VLR04" + CRLF
	cQuery += "	,ISNULL([" + AllTrim(mv_par11) + "], 0) AS VLR05" + CRLF
	cQuery += "	,ISNULL([" + AllTrim(mv_par12) + "], 0) AS VLR06" + CRLF
	cQuery += "FROM (" + CRLF
	cQuery += "	SELECT TRIM(ISNULL(T2.X5_CHAVE, 'N/D')) + ' - ' + TRIM(ISNULL(T2.X5_DESCRI, 'N/D')) CT1_XNAT" + CRLF
	cQuery += "		,T3.AK5_CODIGO + ' - ' + TRIM(T3.AK5_DESCRI) AKD_CO" + CRLF
	cQuery += "		,T0.AKD_TPSALD" + CRLF
	cQuery += "		,SUM(CASE" + CRLF
	cQuery += "				WHEN (T0.AKD_TIPO = '1')" + CRLF
	cQuery += "					THEN T0.AKD_VALOR1" + CRLF
	cQuery += "				ELSE T0.AKD_VALOR1 * - 1" + CRLF
	cQuery += "				END) AKD_VALOR1" + CRLF
	cQuery += "	FROM " + RetSQLName("AKD") + " T0" + CRLF
	cQuery += "	INNER JOIN " + RetSQLName("CT1") + " T1 ON (" + CRLF
	cQuery += "			(T1.CT1_FILIAL = '" + xFilial("CT1") + "')" + CRLF
	cQuery += "			AND (T1.CT1_CONTA = T0.AKD_CO)" + CRLF
	cQuery += "			AND (" + CRLF
	cQuery += "				T1.CT1_XNAT BETWEEN '" + AllTrim(mv_par03) + "'" + CRLF
	cQuery += "					AND '" + AllTrim(mv_par04) + "'" + CRLF
	cQuery += "				)" + CRLF
	cQuery += "			AND (T1.D_E_L_E_T_ = '')" + CRLF
	cQuery += "			)" + CRLF
	cQuery += "	LEFT OUTER JOIN " + RetSQLName("SX5") + " T2 ON (" + CRLF
	cQuery += "			(T2.X5_FILIAL = '" + xFilial("SX5") + "')" + CRLF
	cQuery += "			AND (T2.X5_TABELA = 'Z2')" + CRLF
	cQuery += "			AND (T2.X5_CHAVE = T1.CT1_XNAT)" + CRLF
	cQuery += "			AND (T2.D_E_L_E_T_ = '')" + CRLF
	cQuery += "			)" + CRLF
	cQuery += "	INNER JOIN " + RetSQLName("AK5") + " T3 ON (" + CRLF
	cQuery += "			(T3.AK5_FILIAL = '" + xFilial("AK5") + "')" + CRLF
	cQuery += "			AND (T3.AK5_CODIGO = T0.AKD_CO)" + CRLF
	cQuery += "			AND (T3.D_E_L_E_T_ = '')" + CRLF
	cQuery += "			)" + CRLF
	cQuery += "	WHERE T0.AKD_FILIAL = '" + xFilial("AKD") + "'" + CRLF
	cQuery += "		AND T0.AKD_DATA BETWEEN '" + DToS(mv_par01) + "'" + CRLF
	cQuery += "			AND '" + DToS(mv_par02) + "'" + CRLF
	cQuery += "		AND T0.AKD_CO BETWEEN '" + AllTrim(mv_par05) + "'" + CRLF
	cQuery += "			AND '" + AllTrim(mv_par06) + "'" + CRLF
	cQuery += "		AND T0.AKD_STATUS = '1'" + CRLF
	cQuery += "		AND T0.AKD_TPSALD IN (" + CRLF
	cQuery += "			'" + AllTrim(mv_par07) + "'" + CRLF
	cQuery += "			,'" + AllTrim(mv_par08) + "'" + CRLF
	cQuery += "			,'" + AllTrim(mv_par09) + "'" + CRLF
	cQuery += "			,'" + AllTrim(mv_par10) + "'" + CRLF
	cQuery += "			,'" + AllTrim(mv_par11) + "'" + CRLF
	cQuery += "			,'" + AllTrim(mv_par12) + "'" + CRLF
	cQuery += "			)" + CRLF
	cQuery += "		AND T0.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	GROUP BY T2.X5_CHAVE" + CRLF
	cQuery += "		,T2.X5_DESCRI" + CRLF
	cQuery += "		,T3.AK5_CODIGO" + CRLF
	cQuery += "		,T3.AK5_DESCRI" + CRLF
	cQuery += "		,T0.AKD_TPSALD" + CRLF
	cQuery += "	) P" + CRLF
	cQuery += "PIVOT(SUM(AKD_VALOR1) FOR AKD_TPSALD IN (" + CRLF
	cQuery += "			[" + AllTrim(mv_par07) + "]" + CRLF
	cQuery += "			,[" + AllTrim(mv_par08) + "]" + CRLF
	cQuery += "			,[" + AllTrim(mv_par09) + "]" + CRLF
	cQuery += "			,[" + AllTrim(mv_par10) + "]" + CRLF
	cQuery += "			,[" + AllTrim(mv_par11) + "]" + CRLF
	cQuery += "			,[" + AllTrim(mv_par12) + "]" + CRLF
	cQuery += "			)) AS PT" + CRLF
	cQuery += "ORDER BY CT1_XNAT" + CRLF
	cQuery += "	,AKD_CO" + CRLF

	MPSysOpenQuery(cQuery, cTab)

	DbSelectArea((cTab))
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

		nVlr01   := (cTab)->VLR01
		nVlr02   := Iif(!Empty((cTab)->VLR02), (cTab)->VLR02 - nVlr01, 0)
		nVlr03   := Iif(!Empty((cTab)->VLR03), (cTab)->VLR03 - (cTab)->VLR02, 0)
		nVlr04   := Iif(!Empty((cTab)->VLR04), (cTab)->VLR04 - (cTab)->VLR03, 0)

		oSection2:PrintLine()

		nOrc    += (cTab)->VLR01
		nRet    += nVlr02
		nSup    += nVlr03
		nTransp += nVlr04
		nRev    += (cTab)->VLR05
		nReal   += (cTab)->VLR06

		If (nCont == nRegs)
			oSection1:Finish()
			oSection2:Finish()

			oReport:EndPage()
		Endif

		(cTab)->(DbSkip())
	Enddo

	(cTab)->(DbCloseArea())
Return(lRet)

/*/{Protheus.doc} PCOR23Vld
Relatório de Orçamento de Despesas por Período - Natureza/ Conta
@type function
@author felipe.morais
@since 19/07/2021
/*/

Static Function PCOR23Vld()
	Local lRet   := .T.

	If (mv_par07 == mv_par08)
		lRet := .F.
	Elseif (mv_par07 == mv_par09)
		lRet := .F.
	Elseif (mv_par07 == mv_par10)
		lRet := .F.
	Elseif (mv_par07 == mv_par11)
		lRet := .F.
	Elseif (mv_par07 == mv_par12)
		lRet := .F.
	Elseif (mv_par08 == mv_par09)
		lRet := .F.
	Elseif (mv_par08 == mv_par10)
		lRet := .F.
	Elseif (mv_par08 == mv_par11)
		lRet := .F.
	Elseif (mv_par08 == mv_par12)
		lRet := .F.
	Elseif (mv_par09 == mv_par10)
		lRet := .F.
	Elseif (mv_par09 == mv_par11)
		lRet := .F.
	Elseif (mv_par09 == mv_par12)
		lRet := .F.
	Elseif (mv_par10 == mv_par11)
		lRet := .F.
	Elseif (mv_par10 == mv_par12)
		lRet := .F.
	Elseif (mv_par11 == mv_par12)
		lRet := .F.
	Endif

	If !(lRet)
		Aviso("Aviso", "Não é possível repetir o Tipo de Saldo.", {"Ok"}, 1)
	Endif
Return(lRet)
