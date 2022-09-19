
#INCLUDE "Protheus.ch"
Static nNum    :=1
Static nEmis   :=2
Static nForn   :=3
Static nLoja   :=4
Static nCondPag:=5
Static nFilial :=6

Static nProd  :=7
Static nItem :=8
Static nQntd  :=9
Static nPreco :=10
Static nPrecoT:=11
Static nOpc	  :=12

/*/{Protheus.doc} DWCOMA03
Leitura de CSV - Fornecedores
@type function
@author Gabriel Marques
@since 26/08/2022
/*/

User Function DWCOMA09()
	Local cArquivo  := ""
	Local cLinha    := ""
	Local cUltVar   := ""
	Local lContinua := .T.
	Local aConteudo := {}
	Local aItens := {}
	Local aCabec := {}
	Local aLinha := {}
	Local nI        := 0
//Local nRegs     := 0
	Local oArquivo  := Nil


	Private lMsErroAuto := .F.
	Private cTab        := GetNextAlias()/*"SA2"*/

	cArquivo := cGetFile("Arquivo CSV | *.CSV", "Selecione o arquivo", , "C:\", .T.)

	If !(File(cArquivo))
		MsgInfo("Arquivo não encontrado.", "Aviso")
		lContinua := .F.
	Endif

	If (lContinua)
		oArquivo := FwFileReader():New(cArquivo)
		If (oArquivo:Open())
			If !(oArquivo:Eof())
				While (oArquivo:HasLine())
					cLinha := oArquivo:GetLine()
					aAdd(aConteudo, StrTokArr(cLinha, ";"))
				Enddo
			Endif
		Endif

		If (Len(aConteudo) > 0)
			oArquivo:= FWFileWriter():New("C:\TOTVS12\Workspace\Exemplos\Exercicio_01\Arquivos\Relatorio_Pedido_C.csv", .T.)
			oArquivo:Create()
			For nI := 1 To Len(aConteudo)
				If aConteudo[nI][nNum] == cUltVar
					aLinha := {}
					aadd(aLinha,{"C7_PRODUTO",  aConteudo[nI][nProd], Nil}) // char; tam: 15
					aadd(aLinha,{"C7_QUANT",  Val(aConteudo[nI][nQntd]), Nil}) //num; tam: 12
					aadd(aLinha,{"C7_PRECO",  Val(aConteudo[nI][nPreco]), Nil}) //num; tam: 14
					aadd(aItens, aLinha)
				Else

					if Len(aLinha) > 0
						MSExecAuto({|a,b,c,d,e| MATA120(a,b,c,d,e)}, 1 , aCabec, aItens,  nOpcx, .F.)
						If (lMsErroAuto) //se houver erro
							MostraErro()
						Else
							MsgInfo("Pedido de compra incluido com sucesso.", "Aviso")
						Endif
					Endif

					cUltVar := aConteudo[nI][nNum]
					nOpcX := Val(aConteudo[nI][nOpc])
					aCabec   := {}
					aItens   := {}
					aLinha   := {}
					aadd(aCabec,{"C7_FILIAL", xFilial("SC7"), Nil})
					aadd(aCabec,{"C7_NUM", aConteudo[nI][nNum], Nil}) //char; tam: 6
					aadd(aCabec,{"C7_EMISSAO" , STod(aConteudo[nI][nData]), Nil}) // data; tam 8 // DTos() transforma data em string
					aadd(aCabec,{"C7_FORNECE", aConteudo[nI][nForn], Nil})//char; tam: 6
					aadd(aCabec,{"C7_LOJA", aConteudo[nI][nLoja], Nil})//char; tam: 2
					aadd(aCabec,{"C7_COND",  aConteudo[nI][nCondPag], Nil})//char; tam: 3
					aadd(aCabec,{"C7_FILENT" , aConteudo[nI][nFilEnt]}) //char; tam 2

					aLinha := {}
					aadd(aLinha,{"C7_PRODUTO",  aConteudo[nI][nProd], Nil}) // char; tam: 15
					aadd(aLinha,{"C7_QUANT",  Val(aConteudo[nI][nQntd]), Nil}) //num; tam: 12
					aadd(aLinha,{"C7_PRECO",  Val(aConteudo[nI][nPreco]), Nil}) //num; tam: 14
					aadd(aItens, aLinha)

				Endif

			Next nI

			MSExecAuto({|a,b,c,d,e| MATA120(a,b,c,d,e)}, 1 , aCabec, aItens,  nOpcX, .F.) 

					If (lMsErroAuto)
						MsgInfo("Erro na Importação", "Aviso")
						oArquivo:Write(aConteudo[nI][nNum] +";" + (aConteudo[nI][nEmis]) + ";"+ aConteudo[nI][nForn]+ ";"+aConteudo[nI][nLoja]+ ";"+aConteudo[nI][nCondPag] + ";"+ aConteudo[nI][nFilial] + ";"+  (aConteudo[nI][nProd])+";"+  (aConteudo[nI][nQntd])+";"+  (aConteudo[nI][nPreco])+ ";"+  (aConteudo[nI][nPrecoT])+ " <-ERRO"+CRLF )
					Else
						ConfirmSx8()
						MsgInfo("Importado com Sucesso", "Aviso")
						oArquivo:Write(aConteudo[nI][nNum] +";" + (aConteudo[nI][nEmis]) + ";"+ aConteudo[nI][nForn]+ ";"+aConteudo[nI][nLoja]+ ";"+aConteudo[nI][nCondPag] + ";"+ aConteudo[nI][nFilial] + ";"+  (aConteudo[nI][nProd])+";"+  (aConteudo[nI][nQntd])+";"+  (aConteudo[nI][nPreco])+ ";"+  (aConteudo[nI][nPrecoT])+ "  <-LINHA ESCRITA COM EXITO!"+CRLF )
				Endif
		Endif
		oArquivo:Close()
	Else
		MsgInfo("Nenhum registro encontrado.", "Aviso")
	Endif
	
Return()


