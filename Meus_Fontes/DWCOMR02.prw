#INCLUDE "Protheus.ch" //Blibioteca Protheus

// CRIAR MAIS UMA PERGUNTA PARA ORDENAR O RELAT�RIO.
// Ordenar Por?; Objeto = Combo; Item 1: C�digo. Item 2: Nome. -> Salvar
// ACPCOR16 tem o par�metro de ordenar.

User Function DWCOMR02()
    Local oReport := Nil
	Private cTab := GetNextAlias() // O correto � chamar uma fun��o. GetNextAlias() Pega o nome dispon�vel

	Pergunte("XCLIENTE", .F.) // Caixa de pergunta

	oReport := ReportDef()
	oReport:PrintDialog()



Return()


Static Function ReportDef()
	Local oReport   := Nil
	Local oSection1 := Nil

	oReport := TReport():New("DWCOMR02", "Lista de Clientes","XCLIENTE", {|oReport| ReportPrint(oReport)}, "Imprime lista de todos os Clientes cadastrados no sistema.")
 // oReport := TReport():New([NOME DO RELAT�RIO], [T�TULO],[GRUPO DE PERGUNTAS], {|oReport| ReportPrint(oReport)}, [FUN��O])

	oReport:SetPortrait()

	oSection1 := TRSection():New(oReport) 
	TRCell():New(oSection1, "A1_COD"   , , "C�digo"   , /*cPicture*/, TamSX3("A1_COD")[1]+2   , /*lPixel*/, {||(cTab) ->A1_COD}) //Criar as colunas que v�o aparecer no relat�rio
	TRCell():New(oSection1, "A1_LOJA"   , , "Loja"   , /*cPicture*/, TamSX3("A1_LOJA")[1]   , /*lPixel*/) // N�o informar tabela "sa1"
	TRCell():New(oSection1, "A1_NOME"   , , "Nome"   , /*cPicture*/, TamSX3("A1_NOME")[1]   , /*lPixel*/, {||(cTab) ->A1_NOME}) // Criar novo argumento || IMP-> A1_COD...
	TRCell():New(oSection1, "A1_NREDUZ" , ,"N.Fantasia"   , /*cPicture*/, TamSX3("A1_NREDUZ")[1]   , /*lPixel*/)
	TRCell():New(oSection1, "A1_END"   , , "Endere�o"   , /*cPicture*/, TamSX3("A1_END")[1]   , /*lPixel*/)
	TRCell():New(oSection1, "A1_EST"	, , "Estado"	, /*cPicture*/, TamSX3("A1_EST")[1]   , /*lPixel*/)
	TRCell():New(oSection1, "A1_MUN", , "Munic�pio"	, /*cPicture*/, TamSX3("A1_MUN")[1]   , /*lPixel*/)

	// Adicionado CNPJ/CPF e Data de Nascimento � impress�o do relat�rio	
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
	
	// transformar c�digo SQL 
	// := vari�vel recebe conte�do; += pegar conte�do que tava antes e substitui. [cQuery := cQuery + ...]

    Default oReport := Nil

	cQuery := "SELECT A1_COD" + CRLF //C�digo SQL
	cQuery += "	,A1_NOME" + CRLF //CRLF pula linha
	cQuery += "	,A1_DTNASC" + CRLF
	cQuery += "	,A1_CGC" + CRLF
	cQuery += "FROM " +  RetSQLName("SA1") + CRLF // SA1990 - Para todo cliente, o c�digo da empresa vai variar. Essa rotina tr�s o c�digo da filial que ele est� logado.
	cQuery += "WHERE D_E_L_E_T_ = ''" + CRLF //n�o mostra os deletados
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

	DbSelectArea(cTab) // Usar TMP em todo lugar que faz refer�ncia a SA1
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

