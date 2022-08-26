#INCLUDE "Protheus.ch"
Static nNumPed    := 1
Static nTipoPed  := 2
Static nCliente   := 3
Static nLoja   := 4
Static nTipoCli := 5
Static nCondPag   := 6
Static nCodPro  := 7
Static nQTDVEN :=8
Static nPRCVEN :=9
Static nPRUNIT :=10
Static nVALOR :=11
Static nTES   :=12

User Function DWCOMA04()
	Local nOpcX      := 0
	Local nI         := 0
	Local aCabec     := {}
	Local aItens     := {}
	Local aLinha     := {}
	//leitor de arquivo
	Local cArquivo  := ""
	Local lContinua := .T.
	Local aConteudo := {}
	Local cLinha    := ""
	Local cUltVar := ''
	Private lMsErroAuto := .F.

	cArquivo := cGetFile("Arquivo CSV | *.CSV", "Selecione o arquivo", , "C:\", .T.)

	If !(File(cArquivo))
		MsgInfo("Arquivo n�o encontrado.", "Aviso")
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
	Endif

	If Len(aConteudo) > 0
		For nI := 1 To Len(aConteudo)
			If aConteudo[nI][nNumPed] == cUltVar
				aLinha := {}
				aadd(aLinha,{"C6_ITEM",StrZero(nI,2), Nil}) //StrZero(valor, tamanho)  retorna uma string formatada com zeros à equerda e/ou simbolo decimal.
				aadd(aLinha,{"C6_PRODUTO", aConteudo[nI][nCodPro],Nil})
				aadd(aLinha,{"C6_QTDVEN", Val(aConteudo[nI][nQTDVEN]), Nil})
				aadd(aLinha,{"C6_PRCVEN",  Val(aConteudo[nI][nPRCVEN]), Nil})
				aadd(aLinha,{"C6_TES",aConteudo[nI][nTES], Nil})
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
				cUltVar := aConteudo[nI][nNumPed]
				aCabec   := {}
				aItens   := {}
				aLinha   := {}
				aadd(aCabec, {"C5_NUM",aConteudo[nI][nNumPed],      Nil})
				aadd(aCabec, {"C5_TIPO",aConteudo[nI][nTipoPed],       Nil}) //Tipo de Pedido
				aadd(aCabec, {"C5_CLIENTE", aConteudo[nI][nCliente],    Nil})
				aadd(aCabec, {"C5_LOJACLI", aConteudo[nI][nLoja],   Nil})
				aadd(aCabec, {"C5_LOJAENT", aConteudo[nI][nLoja],   Nil})
				aadd(aCabec, {"C5_CONDPAG", aConteudo[nI][nCondPag], Nil})
				aLinha := {}
				aadd(aLinha,{"C6_ITEM",StrZero(nI,2), Nil}) //StrZero(valor, tamanho)  retorna uma string formatada com zeros à equerda e/ou simbolo decimal.
				aadd(aLinha,{"C6_PRODUTO", aConteudo[nI][nCodPro],Nil})
				aadd(aLinha,{"C6_QTDVEN", Val(aConteudo[nI][nQTDVEN]), Nil})
				aadd(aLinha,{"C6_PRCVEN",  Val(aConteudo[nI][nPRCVEN]), Nil})
				aadd(aLinha,{"C6_TES",aConteudo[nI][nTES], Nil})
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

