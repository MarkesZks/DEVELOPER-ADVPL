SELECT COUNT(*)
FROM (
SELECT SUBSTRING(CT2_DATA, 5, 2) AS MES
	,SUBSTRING(CT2_DATA, 1, 4) AS ANO
	,SUBSTRING(CT2_DATA, 7, 2) + '/' + SUBSTRING(CT2_DATA, 5, 2) + '/' + SUBSTRING(CT2_DATA, 1, 4) AS DATA
	,'010' AS CODUNIDADE
	,CT2_CCD AS CODCENTRODECUSTO
	,RTRIM(CTT_DESC01) AS DESCCENTRODECUSTO
	,CT2_DEBITO AS CODCONTACONTABIL
	,CT1_DESC01 AS DESCCONTACONTABIL
	,RTRIM(CT2_DOC) + '/' + RTRIM(CT2_LOTE) + '/' + RTRIM(CT2_SBLOTE) AS DOCUMENTO
	,'D' AS NATUREZA
	,CT2_VALOR AS VALOR
	,CT2_HIST AS HISTORICO
	,'' CODPROJETO
	,'' GERADOR
	,'N' RATEIO
FROM CT2010 T0
INNER JOIN CT1010 T1 ON CT1_CONTA = CT2_DEBITO
INNER JOIN CTT010 T2 ON CTT_CUSTO = CT2_CCD
WHERE (SUBSTRING(CT2_DEBITO, 1, 1) = '3')
	AND T0.CT2_DATA >= '20220601'
	AND T0.CT2_TPSALD = '1'
	AND T0.D_E_L_E_T_ = ''
	AND T1.D_E_L_E_T_ = ''
	AND T2.D_E_L_E_T_ = ''
UNION ALL
SELECT SUBSTRING(CT2_DATA, 5, 2) AS MES
	,SUBSTRING(CT2_DATA, 1, 4) AS ANO
	,SUBSTRING(CT2_DATA, 7, 2) + '/' + SUBSTRING(CT2_DATA, 5, 2) + '/' + SUBSTRING(CT2_DATA, 1, 4) AS DATA
	,'010' AS CODUNIDADE
	,CASE 
		WHEN CT2_CCC = ''
			THEN '0.88.00'
		ELSE CT2_CCC
		END AS CODCENTRODECUSTO
	,CASE 
		WHEN CT2_CCC = ''
			THEN 'RECEITA'
		ELSE (
				SELECT CTT_DESC01
				FROM CTT010
				WHERE CTT_CUSTO = CT2_CCC
					AND D_E_L_E_T_ = '')
		END AS DESCCENTRODECUSTO
	,CT2_CREDIT AS CODCONTACONTABIL
	,CT1_DESC01 AS DESCCONTACONTABIL
	,RTRIM(CT2_DOC) + '/' + RTRIM(CT2_LOTE) + '/' + RTRIM(CT2_SBLOTE) AS DOCUMENTO
	,'C' AS NATUREZA
	,CT2_VALOR AS VALOR
	,CT2_HIST AS HISTORICO
	,'' CODPROJETO
	,'' GERADOR
	,'N' RATEIO	
FROM CT2010 T0
INNER JOIN CT1010 T1 ON CT1_CONTA = CT2_CREDIT
INNER JOIN CTT010 T2 ON CTT_CUSTO = CT2_CCC
WHERE (SUBSTRING(CT2_CREDIT, 1, 1) = '3')
	AND T0.CT2_DATA >= '20220601'
	AND T0.CT2_TPSALD = '1'
	AND T0.D_E_L_E_T_ = ''
	AND T1.D_E_L_E_T_ = ''
SELECT COUNT(*) 
FROM (FROM CT2010 T0
INNER JOIN CT1010 T1
INNER JOIN CTT010 T2 
)
)AS LINHA
ORDER BY COUNT(*)  ASC;