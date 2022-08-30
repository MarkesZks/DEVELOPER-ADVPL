#Include "Protheus.ch"

Static nMaxLin := 42000

/*/{Protheus.doc} ASFINM01
Exportação de Documentos
@type function
@version 12.1.33
@author DWC
@since 16/05/2022
/*/

User Function ASFINM01()
	Local lRet    := .T.
	Local nHandle := 0

	Private cPath := ""
	Private cSep  := GetNewPar("AS_SEPCSV", ";")
	Private cSeq  := "001"

	cPath := cGetFile("Arquivo .CSV|*.CSV", "Documentos", 1, "C:\", .F., GETF_LOCALHARD, .T., .T.)

	nHandle := FCreate(StrTran(cPath, ".CSV", "") + "_" + StrZero(Val(cSeq), 3) + ".CSV")

	If (nHandle == -1)
		lRet := .F.
		Aviso("Aviso", "Não foi possível criar o arquivo.", {"Ok"}, 1)
	Else
		FWrite(nHandle, 'Documento'            + cSep + ;
			'Natureza'                         + cSep + ;
			'Valor'                            + cSep + ;
			'Código de Unidade'                + cSep + ;
			'Centro de Custo Externo'          + cSep + ;
			'Conta de Tesouraria Externo'      + cSep + ;
			'ERP documento editado'            + cSep + ;
			'Tipo de Documento'                + cSep + ;
			'Classificação Financeira Externa' + cSep + ;
			'Projeto'                          + cSep + ;
			'Previsto Sem Documento'           + cSep + ;
			'Suspenso'                         + cSep + ;
			'Data de Vencimento'               + cSep + ;
			'Data de Liquidação'               + cSep + ;
			'Data de Inclusão'                 + cSep + ;
			'Pendente de Aprovação'            + cSep + ;
			'ERP origem'                       + cSep + ;
			'ERP UUID'                         + cSep + ;
			'Movimento ERP'                    + cSep + ;
			'Data de Emissão'                  + cSep + ;
			'Histórico'                        + cSep + ;
			'Código da Pessoa'                 + CRLF)

		If (FINM01Par())
			Processa({|| FINM01Qry(@nHandle)}, "Exportando movimentos...", "Processando..")
		Endif

		FClose(nHandle)
	Endif
Return(lRet)

/*/{Protheus.doc} FINM01Par
Exportação de Documentos
@type function
@version 12.1.33
@author DWC
@since 16/05/2022
/*/

Static Function FINM01Par()
	Local lRet      := .T.
	Local aParam    := {}
	Local aRet      := {}

	aAdd(aParam, {1, "Data De" , CriaVar("E1_EMISSAO", .T.), PesqPict("SE1", "E1_EMISSAO"), "", ""   , "", 050, .F.})
	aAdd(aParam, {1, "Data Até", CriaVar("E1_EMISSAO", .T.), PesqPict("SE1", "E1_EMISSAO"), "", ""   , "", 050, .T.})

	lRet := ParamBox(aParam, "Parâmetros", @aRet, , , , , , , , , .T.)
Return(lRet)

/*/{Protheus.doc} FINM01Qry
Exportação de Documentos
@type function
@version 12.1.33
@author DWC
@since 16/05/2022
/*/

Static Function FINM01Qry(nHandle)
	Local lRet   := .T.
	Local cQuery := ""
	Local cTab   := ""
	Local cSep   := GetNewPar("AS_SEPCSV", ";")
	Local nRegs  := 0
	Local nI     := 0
	Local nCont  := 0

	Default nHandle := 0

	cQuery := "SELECT T0.E1_PREFIXO + T0.E1_NUM + T0.E1_PARCELA + T0.E1_TIPO 'CODIGO'" + CRLF
	cQuery += "	,'E' 'NATUREZA'" + CRLF
	cQuery += "	,T0.E1_VALOR" + CRLF
	cQuery += "	,T0.E1_FILIAL" + CRLF
	cQuery += "	,T0.E1_CCUSTO" + CRLF
	cQuery += "	,'1' 'DIMENSA1'" + CRLF
	cQuery += "	,'1' 'DIMENSA2'" + CRLF
	cQuery += "	,'1' 'DIMENSA3'" + CRLF
	cQuery += "	,'1' 'DIMENSA4'" + CRLF
	cQuery += "	,'1' 'DIMENSA5'" + CRLF
	cQuery += "	,'1' 'DIMENSA6'" + CRLF
	cQuery += "	,'C' + T1.A1_COD + T1.A1_LOJA A1_CGC" + CRLF
	cQuery += "	,T1.A1_NOME" + CRLF
	cQuery += "	,T1.A1_NREDUZ" + CRLF
	cQuery += "	,T0.E1_NATUREZ" + CRLF
	cQuery += "	,T0.E1_ITEMCTA" + CRLF
	cQuery += "	,T0.E1_CONTA" + CRLF
	cQuery += "	,T0.E1_TIPO 'TIPODOC'" + CRLF
	cQuery += "	,ISNULL(T2.A6_NOME, '') A6_NOME" + CRLF
	cQuery += "	,ISNULL(T2.A6_CARTEIR, '') A6_CARTEIR" + CRLF
	cQuery += "	,T0.E1_EMIS1" + CRLF
	cQuery += "	,T0.E1_EMISSAO" + CRLF
	cQuery += "	,T0.E1_VENCREA" + CRLF
	cQuery += "	,T0.E1_BAIXA" + CRLF
	cQuery += "	,T0.E1_HIST" + CRLF
	cQuery += "	,'N' 'SEMDOC'" + CRLF
	cQuery += "	,'N' 'SUSPENSO'" + CRLF
	cQuery += "	,'N' 'PENDENTE'" + CRLF
	cQuery += "	,'I' 'ORIGEM'" + CRLF
	cQuery += "	,'N' 'E1_DOCED'" + CRLF
	cQuery += "	,T0.R_E_C_N_O_" + CRLF
	cQuery += "	,'Protheus' 'ERP'" + CRLF
	cQuery += "FROM " + RetSQLName("SE1") + " T0" + CRLF
	cQuery += "INNER JOIN " + RetSQLName("SA1") + " T1 ON (" + CRLF
	cQuery += "		(T1.A1_FILIAL = '" + xFilial("SA1") + "')" + CRLF
	cQuery += "		AND (T1.A1_COD = T0.E1_CLIENTE)" + CRLF
	cQuery += "		AND (T1.A1_LOJA = T0.E1_LOJA)" + CRLF
	cQuery += "		AND (T1.D_E_L_E_T_ = '')" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "LEFT OUTER JOIN " + RetSQLName("SA6") + " T2 ON (" + CRLF
	cQuery += "		(T2.A6_FILIAL = '" + xFilial("SA6") + "')" + CRLF
	cQuery += "		AND (T2.A6_COD = T0.E1_BCOCLI)" + CRLF
	cQuery += "		AND (T2.A6_AGENCIA = T0.E1_AGECLI)" + CRLF
	cQuery += "		AND (T2.A6_NUMCON = T0.E1_CTACLI)" + CRLF
	cQuery += "		AND (T2.D_E_L_E_T_ = '')" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "WHERE T0.E1_FILIAL = '" + xFilial("SE1") + "'" + CRLF
	cQuery += "	AND T0.E1_EMISSAO BETWEEN '" + DToS(mv_par01) + "' AND '" + DToS(mv_par02) + "'" + CRLF
	cQuery += "	AND T0.E1_SALDO = 0" + CRLF
	cQuery += "	AND T0.D_E_L_E_T_ = ''" + CRLF
	cQuery += "" + CRLF
	cQuery += "UNION ALL" + CRLF
	cQuery += "" + CRLF
	cQuery += "SELECT T0.E2_PREFIXO + T0.E2_NUM + T0.E2_PARCELA + T0.E2_TIPO 'CODIGO'" + CRLF
	cQuery += "	,'S' 'NATUREZA'" + CRLF
	cQuery += "	,T0.E2_VALOR" + CRLF
	cQuery += "	,T0.E2_FILIAL" + CRLF
	cQuery += "	,T0.E2_CCUSTO" + CRLF
	cQuery += "	,'1' 'DIMENSA1'" + CRLF
	cQuery += "	,'1' 'DIMENSA2'" + CRLF
	cQuery += "	,'1' 'DIMENSA3'" + CRLF
	cQuery += "	,'1' 'DIMENSA4'" + CRLF
	cQuery += "	,'1' 'DIMENSA5'" + CRLF
	cQuery += "	,'1' 'DIMENSA6'" + CRLF
	cQuery += "	,'F' + T1.A2_COD + T1.A2_LOJA A2_CGC" + CRLF
	cQuery += "	,T1.A2_NOME" + CRLF
	cQuery += "	,T1.A2_NREDUZ" + CRLF
	cQuery += "	,T0.E2_NATUREZ" + CRLF
	cQuery += "	,T0.E2_ITEMCTA" + CRLF
	cQuery += "	,T0.E2_CONTAD" + CRLF
	cQuery += "	,T0.E2_TIPO 'TIPODOC'" + CRLF
	cQuery += "	,ISNULL(T2.A6_NOME, '') A6_NOME" + CRLF
	cQuery += "	,ISNULL(T2.A6_CARTEIR, '') A6_CARTEIR" + CRLF
	cQuery += "	,T0.E2_EMIS1" + CRLF
	cQuery += "	,T0.E2_EMISSAO" + CRLF
	cQuery += "	,T0.E2_VENCREA" + CRLF
	cQuery += "	,T0.E2_BAIXA" + CRLF
	cQuery += "	,T0.E2_HIST" + CRLF
	cQuery += "	,'N' 'SEMDOC'" + CRLF
	cQuery += "	,'N' 'SUSPENSO'" + CRLF
	cQuery += "	,'N' 'PENDENTE'" + CRLF
	cQuery += "	,'I' 'ORIGEM'" + CRLF
	cQuery += "	,'S' 'E1_DOCED'" + CRLF
	cQuery += "	,T0.R_E_C_N_O_" + CRLF
	cQuery += "	,'Protheus' 'ERP'" + CRLF
	cQuery += "FROM " + RetSQLName("SE2") + " T0" + CRLF
	cQuery += "INNER JOIN " + RetSQLName("SA2") + " T1 ON (" + CRLF
	cQuery += "		(T1.A2_FILIAL = '" + xFilial("SA2") + "')" + CRLF
	cQuery += "		AND (T1.A2_COD = T0.E2_FORNECE)" + CRLF
	cQuery += "		AND (T1.A2_LOJA = T0.E2_LOJA)" + CRLF
	cQuery += "		AND (T1.D_E_L_E_T_ = '')" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "LEFT OUTER JOIN " + RetSQLName("SA6") + " T2 ON (" + CRLF
	cQuery += "		(T2.A6_FILIAL = '" + xFilial("SA6") + "')" + CRLF
	cQuery += "		AND (T2.A6_COD = T0.E2_FORBCO)" + CRLF
	cQuery += "		AND (T2.A6_AGENCIA = T0.E2_FORAGE)" + CRLF
	cQuery += "		AND (T2.A6_NUMCON = T0.E2_FORCTA)" + CRLF
	cQuery += "		AND (T2.D_E_L_E_T_ = '')" + CRLF
	cQuery += "		)" + CRLF
	cQuery += "WHERE T0.E2_FILIAL = '" + xFilial("SE2") + "'" + CRLF
	cQuery += "	AND T0.E2_EMISSAO BETWEEN '" + DToS(mv_par01) + "' AND '" + DToS(mv_par02) + "'" + CRLF
	cQuery += "	AND T0.E2_SALDO = 0" + CRLF
	cQuery += "	AND T0.D_E_L_E_T_ = ''" + CRLF

	cTab := MPSysOpenQuery(cQuery)

	DbSelectArea((cTab))
	Count To nRegs
	(cTab)->(DbGoTop())

	ProcRegua(nRegs)

	While ((cTab)->(!Eof()))
		nI++
		nCont++
		IncProc("Exportando movimento " + AllTrim(Str(nI)) + " de " + AllTrim(Str(nRegs)))

		If (nCont >= nMaxLin)
			nCont := 0
			cSeq  := Soma1(cSeq)

			FClose(nHandle)

			nHandle := FCreate(StrTran(cPath, ".CSV", "") + "_" + StrZero(Val(cSeq), 3) + ".CSV")

			FWrite(nHandle, 'Documento'            + cSep + ;
				'Natureza'                         + cSep + ;
				'Valor'                            + cSep + ;
				'Código de Unidade'                + cSep + ;
				'Centro de Custo Externo'          + cSep + ;
				'Conta de Tesouraria Externo'      + cSep + ;
				'ERP documento editado'            + cSep + ;
				'Tipo de Documento'                + cSep + ;
				'Classificação Financeira Externa' + cSep + ;
				'Projeto'                          + cSep + ;
				'Previsto Sem Documento'           + cSep + ;
				'Suspenso'                         + cSep + ;
				'Data de Vencimento'               + cSep + ;
				'Data de Liquidação'               + cSep + ;
				'Data de Inclusão'                 + cSep + ;
				'Pendente de Aprovação'            + cSep + ;
				'ERP origem'                       + cSep + ;
				'ERP UUID'                         + cSep + ;
				'Movimento ERP'                    + cSep + ;
				'Data de Emissão'                  + cSep + ;
				'Histórico'                        + cSep + ;
				'Código da Pessoa'                 + CRLF)
		Endif

		FWrite(nHandle, ;
			(cTab)->CODIGO                                                                      + cSep + ;
			(cTab)->NATUREZA                                                                    + cSep + ;
			AllTrim(StrTran(Transform((cTab)->E1_VALOR, PesqPict("SE1", "E1_VALOR")), ".", "")) + cSep + ;
			(cTab)->E1_FILIAL                                                                   + cSep + ;
			(cTab)->E1_CCUSTO                                                                   + cSep + ;
			(cTab)->E1_CONTA                                                                    + cSep + ;
			(cTab)->E1_DOCED                                                                    + cSep + ;
			(cTab)->TIPODOC                                                                     + cSep + ;
			(cTab)->E1_NATUREZ                                                                  + cSep + ;
			(cTab)->E1_ITEMCTA                                                                  + cSep + ;
			(cTab)->SEMDOC                                                                      + cSep + ;
			(cTab)->SUSPENSO                                                                    + cSep + ;
			DToC(SToD((cTab)->E1_VENCREA))                                                      + cSep + ;
			DToC(SToD((cTab)->E1_BAIXA))                                                        + cSep + ;
			DToC(SToD((cTab)->E1_EMIS1))                                                        + cSep + ;
			(cTab)->PENDENTE                                                                    + cSep + ;
			(cTab)->ORIGEM                                                                      + cSep + ;
			Str((cTab)->R_E_C_N_O_)                                                             + cSep + ;
			'Movimento'                                                                         + cSep + ;
			DToC(SToD((cTab)->E1_EMISSAO))                                                      + cSep + ;
			(cTab)->E1_HIST                                                                     + cSep + ;
			(cTab)->A1_CGC                                                                      + CRLF)

		(cTab)->(DbSkip())
	Enddo

	(cTab)->(DbCloseArea())
Return(lRet)
