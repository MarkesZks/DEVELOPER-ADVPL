#INCLUDE "Protheus.ch" //Blibioteca Protheus

// CRIAR MAIS UMA PERGUNTA PARA ORDENAR O RELATÓRIO.
// Ordenar Por?; Objeto = Combo; Item 1: Código. Item 2: Nome. -> Salvar
// ACPCOR16 tem o parâmetro de ordenar.

User Function DWCOMR02()
    Local oReport := Nil
	Private cTab := GetNextAlias() // O correto é chamar uma função. GetNextAlias() Pega o nome disponível

	Pergunte("XCLIENTE", .F.) // Caixa de pergunta

	oReport := ReportDef()
	oReport:PrintDialog()



Return()


Static Function ReportDef()
	Local oReport   := Nil
	Local oSection1 := Nil

	oReport := TReport():New("DWCOMR02", "Lista de Clientes","XCLIENTE", {|oReport| ReportPrint(oReport)}, "Imprime lista de todos os Clientes cadastrados no sistema.")
 // oReport := TReport():New([NOME DO RELATÓRIO], [TÍTULO],[GRUPO DE PERGUNTAS], {|oReport| ReportPrint(oReport)}, [FUNÇÃO])

	oReport:SetPortrait()

	oSection1 := TRSection():New(oReport) 
	TRCell():New(oSection1, "A1_COD"   , , "Código"   , /*cPicture*/, TamSX3("A1_COD")[1]+2   , /*lPixel*/, {||(cTab) ->A1_COD}) //Criar as colunas que vão aparecer no relatório
	TRCell():New(oSection1, "A1_LOJA"   , , "Loja"   , /*cPicture*/, TamSX3("A1_LOJA")[1]   , /*lPixel*/) // Não informar tabela "sa1"
	TRCell():New(oSection1, "A1_NOME"   , , "Nome"   , /*cPicture*/, TamSX3("A1_NOME")[1]   , /*lPixel*/, {||(cTab) ->A1_NOME}) // Criar novo argumento || IMP-> A1_COD...
	TRCell():New(oSection1, "A1_NREDUZ" , ,"N.Fantasia"   , /*cPicture*/, TamSX3("A1_NREDUZ")[1]   , /*lPixel*/)
	TRCell():New(oSection1, "A1_END"   , , "Endereço"   , /*cPicture*/, TamSX3("A1_END")[1]   , /*lPixel*/)
	TRCell():New(oSection1, "A1_EST"	, , "Estado"	, /*cPicture*/, TamSX3("A1_EST")[1]   , /*lPixel*/)
	TRCell():New(oSection1, "A1_MUN", , "Município"	, /*cPicture*/, TamSX3("A1_MUN")[1]   , /*lPixel*/)

	// Adicionado CNPJ/CPF e Data de Nascimento à impressão do relatório	
	TRCell():New(oSection1, "A1_CGC"	, , "CNPJ/CPF"	, /*cPicture*/, TamSX3("A1_CGC")[1]+12   , /*lPixel*/, {||(cTab) ->A1_CGC})
	TRCell():New(oSection1, "A1_DTNASC", , "Data de Nascimento"	, /*cPicture*/, TamSX3("A1_DTNASC")[1]   , /*lPixel*/, {||(cTab) ->A1_DTNASC}) //{||(cTab) ->CAMPO}) Serve para Pegarmos esse campo direto do SQL
	

Return(oReport)


Static Function ReportPrint(oReport)
	Local oSection1 := Nil
    Local nRegs     := 0
    Local nCont     := 0
	Local cQuery := ""
	Local cCodDe := mv_par01 //Ordem de pergunta do grupo de perguntas
	Local cCodAte := mv_par02
	Local cNomeDe := mv_par03
	Local cNomeAte := mv_par04
	Local cCGCDe := mv_par05
	Local cCGCAte := mv_par06
	Local dDtNascDe := mv_par07
	Local dDtNascAte := mv_par08
	Local nOrdem := mv_par09
	
	// transformar código SQL 
	// := variável recebe conteúdo; += pegar conteúdo que tava antes e substitui. [cQuery := cQuery + ...]

    Default oReport := Nil

	cQuery := "SELECT A1_COD" + CRLF //Código SQL
	cQuery += "	,A1_NOME" + CRLF //CRLF pula linha
	cQuery += "	,A1_DTNASC" + CRLF
	cQuery += "	,A1_CGC" + CRLF
	cQuery += "FROM " +  RetSQLName("SA1") + CRLF // SA1990 - Para todo cliente, o código da empresa vai variar. Essa rotina trás o código da filial que ele está logado.
	cQuery += "WHERE D_E_L_E_T_ = ''" + CRLF //não mostra os deletados
	cQuery += "AND A1_FILIAL = '" + xFilial("SA1")+ "'" + CRLF //mostra os registros da filial
	cQuery += "AND A1_COD BETWEEN '" + cCodDe + "'" + CRLF
	cQuery += "AND '" + cCodAte + "'"
	cQuery += "AND A1_NOME BETWEEN '" + cNomeDe + "'" + CRLF
	cQuery += "AND '"+ cNomeate + "'"
	cQuery += "AND A1_CGC BETWEEN '" + cCGCDe + "'" + CRLF
	cQuery += "AND '" + cCGCate + "'"
	cQuery += "AND A1_DTNASC BETWEEN '" + DToS(dDTNASCDe) + "'" + CRLF
	cQuery += "AND '" + DToS(dDTNASCate) + "'"


if nOrdem == 1 
		cQuery += "ORDER BY A1_COD"+ CRLF
elseif nOrdem == 2 
		cQuery += "ORDER BY A1_NOME"+ CRLF
	endif
	
	MPSysOpenQuery(cQuery, (cTab))

	DbSelectArea(cTab) // Usar TMP em todo lugar que faz referência a SA1
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

		oSection1:PrintLine()

		If (nCont == nRegs)
			oSection1:Finish()

			oReport:EndPage()
		Endif

		(cTab)->(DbSkip())
	Enddo

	(cTab)->(DbCloseArea())
Return()

