#INCLUDE "Protheus.ch"

Static nNum		 := 1
Static nForn     := 2
Static nLoja     := 3
Static nCondPag	 := 4
Static nProd     := 5
Static nQntd     := 6
Static nPreco	 := 7
Static nOpc	 	 := 8

//CA120NUM CA120FORN CA120LOJ CCONDICAO
//C7_PRODUTO C7_QUANT C7_PRECO

// C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN

User Function DWCOMA08()
	Local cArquivo  := ""
	Local cLinha    := ""
	Local lContinua := .T.
	Local aConteudo := {}
	Local aLinha    := {}
	Local nI        := 0
//	Local nRegs     := 0
	Local oArquivo  := Nil
	Local cUltVar  := ""

	Private lMsErroAuto := .F.
	Private cTab        := GetNextAlias()

	cArquivo := cGetFile("Arquivo CSV | *.CSV", "Selecione o arquivo", , "C:\", .T.)

	If !File(cArquivo)
		MsgInfo("O arquivo não existe", "Aviso")
		lContinua := .F.
	Endif

	If (lContinua)
		oArquivo := FwFileReader():New(cArquivo)
		If (oArquivo:Open())
			If!(oArquivo:Eof())
				While (oArquivo:HasLine())
					cLinha := oArquivo:GetLine()
					aAdd(aConteudo, StrTokArr(cLinha, ";"))
				Enddo
			Endif
		Endif

		If Len(aConteudo) > 0
			oArquivo := FwFileWriter():New("C:\TOTVS12\Workspace\Exemplos\Exercicio_01\Arquivos\Relatorio_Pedido_C.csv", .T.)
			oArquivo:Create()

			For nI := 1 To Len(aConteudo)
				If aConteudo[nI][nNum] == cUltVar
					aLinha := {}
					aadd(aLinha,{"C7_PRODUTO", aConteudo[nI][nProd], Nil})
					aadd(aLinha,{"C7_QUANT", aConteudo[nI][nQntd],Nil})
					aadd(aLinha,{"C7_PRECO", aConteudo[nI][nPreco], Nil})
					aadd(aItens, aLinha)
				else
					if Len(aLinha) > 0
						MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens,  Val(aConteudo[nI][nOpc]), .F.)
						If (lMsErroAuto)
							MsgInfo("Erro na Importação", "Aviso")
							oArquivo:Write(aConteudo[nI][nNum] + ";" + aConteudo[nI][nForn] + ";" + aConteudo[nI][nLoja] + ";" + aConteudo[nI][nCondPag] + ";" + aConteudo[nI][nProd] + ";" + aConteudo[nI][nQntd] + ";" + aConteudo[nI][nPreco] + "<= Erro" + CRLF)
						Else
							MsgInfo("Pedido de Compra incluido com sucesso.", "Aviso")
							oArquivo:Write(aConteudo[nI][nNum] + ";" + aConteudo[nI][nForn] + ";" + aConteudo[nI][nLoja] + ";" + aConteudo[nI][nCondPag] + ";" + aConteudo[nI][nProd] + ";" + aConteudo[nI][nQntd] + ";" + aConteudo[nI][nPreco] + "<= Incluido com sucesso" + CRLF)
						Endif
					Endif

					cUltVar := aConteudo[nI][nNum]
					aCabec   := {}
					aItens   := {}
					aLinha   := {}
					aadd(aCabec,{"CA120NUM", aConteudo[nI][nNum], Nil})
					aadd(aCabec,{"CA120FORN", aConteudo[nI][nForn],Nil})
					aadd(aCabec,{"CA120LOJ", aConteudo[nI][nLoja], Nil})
					aadd(aCabec,{"CCONDICAO",  aConteudo[nI][nCondPag], Nil})
					aLinha := {}
					aadd(aLinha,{"C7_PRODUTO", aConteudo[nI][nProd], Nil})
					aadd(aLinha,{"C7_QUANT", aConteudo[nI][nQntd],Nil})
					aadd(aLinha,{"C7_PRECO", aConteudo[nI][nPreco], Nil})
					aadd(aItens, aLinha)
				Endif
			Next nI

			MSExecAuto({|a, b, c, d| MATA121(a, b, c, d)}, aCabec, aItens,  Val(aConteudo[nI][nOpc]), .F.) //erro aqui
			
			If (lMsErroAuto)
				MsgInfo("Erro na Importação", "Aviso")
				oArquivo:Write(aConteudo[nI][nNum] + ";" + aConteudo[nI][nForn] + ";" + aConteudo[nI][nLoja] + ";" + aConteudo[nI][nCondPag] + ";" + aConteudo[nI][nProd] + ";" + aConteudo[nI][nQntd] + ";" + aConteudo[nI][nPreco] + "<= Erro" + CRLF)
			Else
				MsgInfo("Pedido de Compra incluido com sucesso.", "Aviso")
				oArquivo:Write(aConteudo[nI][nNum] + ";" + aConteudo[nI][nForn] + ";" + aConteudo[nI][nLoja] + ";" + aConteudo[nI][nCondPag] + ";" + aConteudo[nI][nProd] + ";" + aConteudo[nI][nQntd] + ";" + aConteudo[nI][nPreco] + "<= Incluido com sucesso" + CRLF)
			Endif
		Else
			MsgInfo("Nenhum registro encontrado.", "Aviso")
		Endif
	Endif
Return ()
