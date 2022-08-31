#INCLUDE "Protheus.ch"

Static nNum		 := 1 //posição na linha // Número do Pedido de Vendas
Static nTipo     := 2
Static nCliente  := 3
Static nLoja     := 4
Static nTipoCli  := 5
Static nCondPag	 := 6
Static nProd     := 7
Static nQntd     := 8
Static nPrUnit 	 := 9
Static nTes      := 10

User Function DWCOMA04()

	//Local aPedVenda  := {}
	//Local cNum       := 0     // Número do Pedido de Vendas
	//Local cCodCli    := "002"  // Código do Cliente - 002 Cliente 1
	//Local cLoja      := "01"   // Loja do Cliente
	//Local cCodPro    := "001"  // Código do Produto - 001 Produto 1
	//Local cTES       := "503"  // Código do TES - Tipo de Saída
	//Local cCondPgto  := "001"  // Código da Condição de Pagamento
	Local nOpcX      := 0
	Local nI         := 0
	Local aCabec     := {}
	Local aItens     := {}
	Local aLinha     := {}

	Local aConteudo  := {}
	Local cLinha     := ""
	Local cArquivo   := ""
	Local lContinua  := .T.
	Local cUltVar  := ""

	//Local nRegs     := 0 //recebe valor de retorno do select
	//Local cTab      := GetNextAlias()

	Private lMsErroAuto := .F.
	//cNum := GetSxeNum("SC5", "C5_NUM") // pega o próximo numero disponível


	// ----- Arquivo CSV ----- //
	cArquivo := cGetFile("Arquivo CSV | *.CSV", "Selecione o arquivo", , "C:\", .T.)
	//          cGetFile ( [nome do arquivo], [Título], , [Diretório], [.T. salva; .F. Abre])
	//  C5_NUM;C5_TIPO;C5_CLIENTE;C5_LOJACLI;C5_TIPOCLI;C5_CONDPAG;C6_ITEM;C6_PRODUTO;C6_QTDVEN;C6_PRCVEN;C6_TES

	If !(File(cArquivo)) // verifica se ele existe
		MsgInfo("Arquivo n�o encontrado.", "Aviso")
		lContinua := .F.
	Endif

	If (lContinua)
		oArquivo := FwFileReader():New(cArquivo) //le arquivo
		If (oArquivo:Open())
			iF !(oArquivo:Eof())
				while (oArquivo:HasLine()) //enquanto tiver linha, ele vai lendo
					cLinha := oArquivo:GetLine() //le a linha
					aAdd(aConteudo, StrTokArr(cLinha, ";")) //conteúdo de cada linha
				ENDDO
			Endif
		Endif
	Endif

        /*
        TIPO PEDIDO C5_TIPO - N
        CLIENTE C5_CLIENTE - 001
        LOJA C5_LOJACLI - AUTOMATICO
        TIPO CLIENTE C5_TIPOCLI - AUT
        COND. PAGTO C5_CONDPAG - 001
        PRODUTO C6_PRODUTO - 001
        QUANTIDADE C6_QTDVEN
        PREÇO C6_PRCVEN
        TIPO SAÝDA C6_TES 
        */

	//--- Informando os dados do item do Pedido de Venda--- //

	If Len(aConteudo) > 0
		For nI := 1 To Len(aConteudo)
			If aConteudo[nI][nNum] == cUltVar
				aLinha := {}
				aadd(aLinha,{"C6_ITEM",StrZero(nI,2), Nil}) //StrZero(valor, tamanho)  retorna uma string formatada com zeros �  equerda e/ou simbolo decimal.
				aadd(aLinha,{"C6_PRODUTO", aConteudo[nI][nProd],Nil})
				aadd(aLinha,{"C6_QTDVEN", Val(aConteudo[nI][nQntd]), Nil})
				aadd(aLinha,{"C6_PRCVEN",  Val(aConteudo[nI][nPrUnit]), Nil})
				aadd(aLinha,{"C6_TES",aConteudo[nI][nTes], Nil})
				aadd(aItens, aLinha)
			else
				if Len(aLinha) > 0
					nOpcX := 3
					MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)
					If (lMsErroAuto) //se houver erro
						MostraErro()
					Else
						MsgInfo("Pedido de Venda incluido com sucesso.", "Aviso")
					Endif
				Endif

				cUltVar := aConteudo[nI][nNum]
				aCabec   := {}
				aItens   := {}
				aLinha   := {}
				aadd(aCabec, {"C5_NUM",aConteudo[nI][nNum],      Nil})
				aadd(aCabec, {"C5_TIPO",aConteudo[nI][nTipo],       Nil}) //Tipo de Pedido
				aadd(aCabec, {"C5_CLIENTE", aConteudo[nI][nCliente],    Nil})
				aadd(aCabec, {"C5_LOJACLI", aConteudo[nI][nLoja],   Nil})
				aadd(aCabec, {"C5_CONDPAG", aConteudo[nI][nCondPag], Nil})
				aLinha := {}
				aadd(aLinha,{"C6_ITEM",StrZero(nI,2), Nil}) //StrZero(valor, tamanho)  retorna uma string formatada com zeros �  equerda e/ou simbolo decimal.
				aadd(aLinha,{"C6_PRODUTO", aConteudo[nI][nProd],Nil})
				aadd(aLinha,{"C6_QTDVEN", Val(aConteudo[nI][nQntd]), Nil})
				aadd(aLinha,{"C6_PRCVEN",  Val(aConteudo[nI][nPrUnit]), Nil})
				aadd(aLinha,{"C6_TES",aConteudo[nI][nTes], Nil})
				aadd(aItens, aLinha)
			Endif
		Next nI

		nOpcX := 3
		MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)
		If (lMsErroAuto) //se houver erro
			MostraErro()
		Else
			MsgInfo("Pedido de Venda incluido com sucesso.", "Aviso")
		Endif
	Else
		MsgInfo("Nenhum registro encontrado.", "Aviso")
	Endif

Return ()

