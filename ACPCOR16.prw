#Include "Protheus.ch"

/*/{Protheus.doc} ACPCOR16
Relatório de Orçamento de Despesas por Período - Conta
@type function
@author felipe.morais
@since 07/12/2021
/*/

User Function ACPCOR16()
	Local lRet      := .T.
	Local oReport   := Nil
	Local cTab      := GetNextAlias()

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

	If (PCOR16Par())
		If (PCOR16Vld())
			oReport := ReportDef(cTab)
			oReport:PrintDialog()
		Endif
	Endif
Return(lRet)

/*/{Protheus.doc} PCOR16Par
Relatório de Orçamento de Despesas por Período - Conta
@type function
@author felipe.morais
@since 07/12/2021
/*/

Static Function PCOR16Par()
	Local lRet   := .T.
	Local aParam := {}
	Local aRet   := {}

	aAdd(aParam, {1, "Data De"     , CriaVar("AKD_DATA", .T.)  , PesqPict("AKD", "AKD_DATA")  , "", ""    , "", 50, .F.})
	aAdd(aParam, {1, "Data Até"    , CriaVar("AKD_DATA", .T.)  , PesqPict("AKD", "AKD_DATA")  , "", ""    , "", 50, .T.})
	aAdd(aParam, {1, "CO De"       , CriaVar("AKD_CO", .T.)    , PesqPict("AKD", "AKD_CO")    , "", "AK5" , "", 80, .F.})
	aAdd(aParam, {1, "CO Até"      , CriaVar("AKD_CO", .T.)    , PesqPict("AKD", "AKD_CO")    , "", "AK5" , "", 80, .T.})
	aAdd(aParam, {1, "UO De"       , CriaVar("AKD_CC", .T.)    , PesqPict("AKD", "AKD_CC")    , "", "CTT" , "", 80, .F.})
	aAdd(aParam, {1, "UO Até"      , CriaVar("AKD_CC", .T.)    , PesqPict("AKD", "AKD_CC")    , "", "CTT" , "", 80, .T.})
	aAdd(aParam, {1, "CR De"       , CriaVar("AKD_ITCTB", .T.) , PesqPict("AKD", "AKD_ITCTB") , "", "CTD" , "", 80, .F.})
	aAdd(aParam, {1, "CR Até"      , CriaVar("AKD_ITCTB", .T.) , PesqPict("AKD", "AKD_ITCTB") , "", "CTD" , "", 80, .T.})
	aAdd(aParam, {1, "Orçado"      , CriaVar("AKD_TPSALD", .T.), PesqPict("AKD", "AKD_TPSALD"), "", "AL2A", "", 25, .T.})
	aAdd(aParam, {1, "Retificado"  , CriaVar("AKD_TPSALD", .T.), PesqPict("AKD", "AKD_TPSALD"), "", "AL2A", "", 25, .T.})
	aAdd(aParam, {1, "Suplementado", CriaVar("AKD_TPSALD", .T.), PesqPict("AKD", "AKD_TPSALD"), "", "AL2A", "", 25, .T.})
	aAdd(aParam, {1, "Transposto"  , CriaVar("AKD_TPSALD", .T.), PesqPict("AKD", "AKD_TPSALD"), "", "AL2A", "", 25, .T.})
	aAdd(aParam, {1, "Revisado"    , CriaVar("AKD_TPSALD", .T.), PesqPict("AKD", "AKD_TPSALD"), "", "AL2A", "", 25, .T.})
	aAdd(aParam, {1, "Realizado"   , CriaVar("AKD_TPSALD", .T.), PesqPict("AKD", "AKD_TPSALD"), "", "AL2A", "", 25, .T.})

	lRet := ParamBox(aParam, "Parâmetros", @aRet, , , , , , , , , .T.)
Return(lRet)

/*/{Protheus.doc} ReportDef
Relatório de Orçamento de Despesas por Período - Conta
@type function
@author felipe.morais
@since 07/12/2021
/*/

Static Function ReportDef(cTab)
	Local oReport   := Nil
	Local oSection1 := Nil
	Local oBreak1   := Nil
	Local cTxt1     := OemToAnsi("Total de Despesas")

	oReport := TReport():New("ACPCOR16", OemToAnsi("Orçamento de Despesas por Período - Conta"), Nil, {|oReport| ReportPrint(oReport, cTab)}, OemToAnsi("Orçamento de Despesas por Período - Conta"))

	oReport:SetPortrait()
	oReport:SetFile("ACPCOR16")
	oReport:ShowHeader()

	oSection1 := TRSection():New(oReport)
	oSection1:SetLineStyle(.F.)
	TRCell():New(oSection1, "AKD_CO", /*cAlias*/, OemToAnsi("Contas Orçamentárias"), /*cPicture*/                 , 120, /*lPixel*/, {|| (cTab)->AKD_CO})
	TRCell():New(oSection1, "VLR01" , /*cAlias*/, OemToAnsi("Orçado")              , PesqPict("AKD", "AKD_VALOR1"), 040, /*lPixel*/, {|| nVlr01}        )
	TRCell():New(oSection1, "VLR02" , /*cAlias*/, OemToAnsi("Retificado")          , PesqPict("AKD", "AKD_VALOR1"), 040, /*lPixel*/, {|| nVlr02}        )
	TRCell():New(oSection1, "VLR03" , /*cAlias*/, OemToAnsi("Suplementado")        , PesqPict("AKD", "AKD_VALOR1"), 040, /*lPixel*/, {|| nVlr03}        )
	TRCell():New(oSection1, "VLR04" , /*cAlias*/, OemToAnsi("Transposto")          , PesqPict("AKD", "AKD_VALOR1"), 040, /*lPixel*/, {|| nVlr04}        )
	TRCell():New(oSection1, "VLR05" , /*cAlias*/, OemToAnsi("Revisado")            , PesqPict("AKD", "AKD_VALOR1"), 040, /*lPixel*/, {|| (cTab)->VLR05} )
	TRCell():New(oSection1, "VLR06" , /*cAlias*/, OemToAnsi("Realizado")           , PesqPict("AKD", "AKD_VALOR1"), 040, /*lPixel*/, {|| (cTab)->VLR06} )

	oBreak1 := TRBreak():New(oSection1, {|| .F.}, /*uTitle*/, /*lTotalInLine*/, /*cName*/, /*lPageBreak*/)

	TRFunction():New(oSection1:Cell("AKD_CO"), /*cID*/, "ONPRINT", oBreak1, /**/, /*cPicture*/                 , {|| cTxt1}  , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/, /*oParent*/, /*bCondition*/, /*lDisable*/, /*bCanPrint*/)
	TRFunction():New(oSection1:Cell("VLR01") , /*cID*/, "ONPRINT", oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), {|| nOrc}   , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection1:Cell("VLR02") , /*cID*/, "ONPRINT", oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), {|| nRet}   , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection1:Cell("VLR03") , /*cID*/, "ONPRINT", oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), {|| nSup}   , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection1:Cell("VLR04") , /*cID*/, "ONPRINT", oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), {|| nTransp}, .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection1:Cell("VLR05") , /*cID*/, "ONPRINT", oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), {|| nRev}   , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
	TRFunction():New(oSection1:Cell("VLR06") , /*cID*/, "ONPRINT", oBreak1, /**/, PesqPict("AKD", "AKD_VALOR1"), {|| nReal}  , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/)
Return(oReport)

/*/{Protheus.doc} ReportPrint
Relatório de Orçamento de Despesas por Período - Conta
@type function
@author felipe.morais
@since 07/12/2021
/*/

Static Function ReportPrint(oReport, cTab)
	Local lRet      := .T.
	Local oSection1 := Nil
	Local nRegs     := 0
	Local nCont     := 0
	Local cQuery    := ""
	Local lO1       := PCOR16Mov(AllTrim(mv_par09))
	Local lO2       := PCOR16Mov(AllTrim(mv_par10))
	Local lO3       := PCOR16Mov(AllTrim(mv_par11))
	Local lO4       := PCOR16Mov(AllTrim(mv_par12))

	cQuery := "SELECT AKD_CO" + CRLF
	cQuery += "	,ISNULL([" + AllTrim(mv_par09) + "], 0) AS VLR01" + CRLF
	cQuery += "	,ISNULL([" + AllTrim(mv_par10) + "], 0) AS VLR02" + CRLF
	cQuery += "	,ISNULL([" + AllTrim(mv_par11) + "], 0) AS VLR03" + CRLF
	cQuery += "	,ISNULL([" + AllTrim(mv_par12) + "], 0) AS VLR04" + CRLF
	cQuery += "	,ISNULL([" + AllTrim(mv_par13) + "], 0) AS VLR05" + CRLF
	cQuery += "	,ISNULL([" + AllTrim(mv_par14) + "], 0) AS VLR06" + CRLF
	cQuery += "FROM (" + CRLF
	cQuery += "	SELECT T1.AK5_CODIGO + ' - ' + TRIM(T1.AK5_DESCRI) AKD_CO" + CRLF
	cQuery += "		,T0.AKD_TPSALD" + CRLF
	cQuery += "		,SUM(CASE" + CRLF
	cQuery += "				WHEN (T0.AKD_TIPO = '1')" + CRLF
	cQuery += "					THEN T0.AKD_VALOR1" + CRLF
	cQuery += "				ELSE T0.AKD_VALOR1 * - 1" + CRLF
	cQuery += "				END) AKD_VALOR1" + CRLF
	cQuery += "	FROM " + RetSQLName("AKD") + " T0" + CRLF
	cQuery += "	INNER JOIN " + RetSQLName("AK5") + " T1 ON (" + CRLF
	cQuery += "			(T1.AK5_FILIAL = '" + xFilial("AK5") + "')" + CRLF
	cQuery += "			AND (T1.AK5_CODIGO = T0.AKD_CO)" + CRLF
	cQuery += "			AND (T1.D_E_L_E_T_ = '')" + CRLF
	cQuery += "			)" + CRLF
	cQuery += "	WHERE T0.AKD_FILIAL = '" + xFilial("AKD") + "'" + CRLF
	cQuery += "		AND T0.AKD_DATA BETWEEN '" + DToS(mv_par01) + "'" + CRLF
	cQuery += "			AND '" + DToS(mv_par02) + "'" + CRLF
	cQuery += "		AND T0.AKD_CO BETWEEN '" + AllTrim(mv_par03) + "'" + CRLF
	cQuery += "			AND '" + AllTrim(mv_par04) + "'" + CRLF
	cQuery += "		AND T0.AKD_CC BETWEEN '" + AllTrim(mv_par05) + "'" + CRLF
	cQuery += "			AND '" + AllTrim(mv_par06) + "'" + CRLF
	cQuery += "		AND T0.AKD_ITCTB BETWEEN '" + AllTrim(mv_par07) + "'" + CRLF
	cQuery += "			AND '" + AllTrim(mv_par08) + "'" + CRLF
	cQuery += "		AND T0.AKD_STATUS = '1'" + CRLF
	cQuery += "		AND T0.AKD_TPSALD IN (" + CRLF
	cQuery += "			'" + AllTrim(mv_par09) + "'" + CRLF
	cQuery += "			,'" + AllTrim(mv_par10) + "'" + CRLF
	cQuery += "			,'" + AllTrim(mv_par11) + "'" + CRLF
	cQuery += "			,'" + AllTrim(mv_par12) + "'" + CRLF
	cQuery += "			,'" + AllTrim(mv_par13) + "'" + CRLF
	cQuery += "			,'" + AllTrim(mv_par14) + "'" + CRLF
	cQuery += "			)" + CRLF
	cQuery += "		AND T0.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	GROUP BY T1.AK5_CODIGO" + CRLF
	cQuery += "		,T1.AK5_DESCRI" + CRLF
	cQuery += "		,T0.AKD_TPSALD" + CRLF
	cQuery += "	) P" + CRLF
	cQuery += "PIVOT(SUM(AKD_VALOR1) FOR AKD_TPSALD IN (" + CRLF
	cQuery += "			[" + AllTrim(mv_par09) + "]" + CRLF
	cQuery += "			,[" + AllTrim(mv_par10) + "]" + CRLF
	cQuery += "			,[" + AllTrim(mv_par11) + "]" + CRLF
	cQuery += "			,[" + AllTrim(mv_par12) + "]" + CRLF
	cQuery += "			,[" + AllTrim(mv_par13) + "]" + CRLF
	cQuery += "			,[" + AllTrim(mv_par14) + "]" + CRLF
	cQuery += "			)) AS PT" + CRLF
	cQuery += "WHERE (" + CRLF
	cQuery += "		([" + AllTrim(mv_par09) + "] <> 0)" + CRLF
	cQuery += "		OR ([" + AllTrim(mv_par10) + "] <> 0)" + CRLF
	cQuery += "		OR ([" + AllTrim(mv_par11) + "] <> 0)" + CRLF
	cQuery += "		OR ([" + AllTrim(mv_par12) + "] <> 0)" + CRLF
	cQuery += "		OR ([" + AllTrim(mv_par13) + "] <> 0)" + CRLF
	cQuery += "		OR ([" + AllTrim(mv_par14) + "] <> 0)" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "ORDER BY AKD_CO" + CRLF

	MPSysOpenQuery(cQuery, cTab)

	DbSelectArea((cTab))
	Count To nRegs
	(cTab)->(DbGoTop())

	If (!Empty(nRegs))
		oReport:SetMeter(nRegs)

		oSection1 := oReport:Section(1)
		oSection1:Init()
	Endif

	While ((cTab)->(!Eof()))
		nCont++
		oReport:IncMeter()

		If (lO1)
			nVlr01 := (cTab)->VLR01
		Else
			nVlr01 := 0
		Endif

		If (lO2)
			nVlr02 := (cTab)->VLR02 - (cTab)->VLR01
		Else
			nVlr02 := 0
		Endif

		If (lO3)
			nVlr03 := (cTab)->VLR03 - (cTab)->VLR02
		Else
			nVlr03 := 0
		Endif

		If (lO4)
			nVlr04 := (cTab)->VLR04 - (cTab)->VLR03
		Else
			nVlr04 := 0
		Endif

		oSection1:PrintLine()

		nOrc    += (cTab)->VLR01
		nRet    += nVlr02
		nSup    += nVlr03
		nTransp += nVlr04
		nRev    += (cTab)->VLR05
		nReal   += (cTab)->VLR06

		If (nCont == nRegs)
			oSection1:Finish()

			oReport:EndPage()
		Endif

		(cTab)->(DbSkip())
	Enddo

	(cTab)->(DbCloseArea())
Return(lRet)

/*/{Protheus.doc} PCOR16Vld
Relatório de Orçamento de Despesas por Período - Conta
@type function
@author felipe.morais
@since 07/12/2021
/*/

Static Function PCOR16Vld()
	Local lRet   := .T.

	If (mv_par09 == mv_par10)
		lRet := .F.
	Elseif (mv_par09 == mv_par11)
		lRet := .F.
	Elseif (mv_par09 == mv_par12)
		lRet := .F.
	Elseif (mv_par09 == mv_par13)
		lRet := .F.
	Elseif (mv_par09 == mv_par14)
		lRet := .F.
	Elseif (mv_par10 == mv_par11)
		lRet := .F.
	Elseif (mv_par10 == mv_par12)
		lRet := .F.
	Elseif (mv_par10 == mv_par13)
		lRet := .F.
	Elseif (mv_par10 == mv_par14)
		lRet := .F.
	Elseif (mv_par11 == mv_par12)
		lRet := .F.
	Elseif (mv_par11 == mv_par13)
		lRet := .F.
	Elseif (mv_par11 == mv_par14)
		lRet := .F.
	Elseif (mv_par12 == mv_par13)
		lRet := .F.
	Elseif (mv_par12 == mv_par14)
		lRet := .F.
	Elseif (mv_par13 == mv_par14)
		lRet := .F.
	Endif

	If !(lRet)
		Aviso("Aviso", "Não é possível repetir o Tipo de Saldo.", {"Ok"}, 1)
	Endif
Return(lRet)

/*/{Protheus.doc} PCOR16Mov
Relatório de Orçamento de Despesas por Período - Unidade/Conta
@type function
@author felipe.morais
@since 26/07/2021
/*/

Static Function PCOR16Mov(cTpSaldo)
	Local lRet   := .T.
	Local cQuery := ""
	Local cTab   := ""
	Local nRegs  := 0

	Default cTpSaldo := ""

	cQuery := "SELECT COUNT(T0.AKD_FILIAL) REGS" + CRLF
	cQuery += "FROM " + RetSQLName("AKD") + " T0" + CRLF
	cQuery += "INNER JOIN " + RetSQLName("CTT") + " T1 ON (" + CRLF
	cQuery += "		(T1.CTT_FILIAL = '" + xFilial("CTT") + "')" + CRLF
	cQuery += "		AND (T1.CTT_CUSTO = T0.AKD_CC)" + CRLF
	cQuery += "		AND (T1.D_E_L_E_T_ = '')" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "WHERE T0.AKD_FILIAL = '" + xFilial("AKD") + "'" + CRLF
	cQuery += "	AND T0.AKD_DATA BETWEEN '" + DToS(mv_par01) + "'" + CRLF
	cQuery += "		AND '" + DToS(mv_par02) + "'" + CRLF
	cQuery += "	AND T0.AKD_CO BETWEEN '" + AllTrim(mv_par03) + "'" + CRLF
	cQuery += "		AND '" + AllTrim(mv_par04) + "'" + CRLF
	cQuery += "	AND T0.AKD_CC BETWEEN '" + AllTrim(mv_par05) + "'" + CRLF
	cQuery += "		AND '" + AllTrim(mv_par06) + "'" + CRLF
	cQuery += "	AND T0.AKD_ITCTB BETWEEN '" + AllTrim(mv_par07) + "'" + CRLF
	cQuery += "		AND '" + AllTrim(mv_par08) + "'" + CRLF
	cQuery += "	AND T0.AKD_STATUS = '1'" + CRLF
	cQuery += "	AND T0.AKD_TPSALD = '" + cTpSaldo + "'" + CRLF
	cQuery += "	AND T0.D_E_L_E_T_ = ' '" + CRLF

	cTab := MPSysOpenQuery(cQuery)

	DbSelectArea((cTab))
	(cTab)->(DbGoTop())

	While ((cTab)->(!Eof()))
		nRegs := (cTab)->REGS

		(cTab)->(DbSkip())
	Enddo

	(cTab)->(DbCloseArea())

	lRet := !Empty(nRegs)
Return(lRet)
