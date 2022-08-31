//Importaçao de Fornecedores 
#INCLUDE "Protheus.ch"
Static nNum		 := 1
Static nForn     := 2
Static nLoja     := 3
Static nCondPag	 := 4
Static nProd     := 5
Static nQntd     := 6
Static nPreco	 := 7
Static nOpc	 	 := 8


/*/{Protheus.doc} DWCOMA03
Leitura de CSV - Fornecedores
@type function
@author Gabriel Marques
@since 26/08/2022
/*/

User Function DWCOMA07()
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

				cQuery += "SELECT C7_FORNECE"+ CRLF
				cQuery += ",C7_LOJA   " + CRLF
				cQuery += ",C7_COND   " + CRLF
				cQuery += ",C7_ITEM   " + CRLF
				cQuery += ",C7_PRODUTO" + CRLF
				cQuery += ",C7_QUANT  " + CRLF
				cQuery += ",C7_PRECO  " + CRLF
				cQuery += ",C7_TOTAL FROM " + RetSQLName("SC7") + CRLF
				cQuery += "	WHERE D_E_L_E_T_ = ''" + CRLF
				MPSysOpenQuery(cQuery, cTab)

				DbSelectArea((cTab))
				(cTab)->(DbGoTop())

				nRegs := 0

				While ((cTab)->(!Eof()))
					nRegs := (cTab)->REGS

					(cTab)->(DbSkip())
				ENDDO

				(cTab)->(DbCloseArea())

				If ((nRegs == 1))
					MsgInfo("Pedido de Compra já efetuado.", "Aviso")
				Else
					If (Val(aConteudo[nI][nEscolha]) == 4 .Or. Val(aConteudo[nI][nEscolha]) == 5)
						DbSelectArea("SC7")
						SA2->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
						SA2->(DbSeek(xFilial("SC7") + PadR(aConteudo[nI][nForn], 6) + PadR(aConteudo[nI][nLoja], 2)))
					Endif

					aPedidos := {{"A2_COD"   , PadR(aConteudo[nI][nCod], 6) ,	Nil},;
						{"A2_LOJA"   , PadR(aConteudo[nI][nLoja],2),	Nil},;
						{"A2_NOME"   , aConteudo[nI][nNome],	Nil},;
						{"A2_NREDUZ" , aConteudo[nI][nNomeRedu],Nil},;
						{"A2_END"    , aConteudo[nI][nEndereco],Nil},;
						{"A2_EST"    , AllTrim(aConteudo[nI][nEstad]),Nil},;
						{"A2_COD_MUN", aConteudo[nI][nCodMun],Nil},;
						{"A2_MUN"		 , aConteudo[nI][nMun] ,Nil},;
						{"A2_TIPO"   , aConteudo[nI][nTipo],Nil}}

					MsExecAuto({|x,y| MATA020(x,y)}, aPedidos, Val(aConteudo[nI][nEscolha]))

					If (lMsErroAuto)

						MsgInfo("Erro na Importação", "Aviso")
						oArquivo:Write(aConteudo[nI][nCod] +";" + PadR(aConteudo[nI][nCod], 6) + ";"+ aConteudo[nI][nNome]+ ";"+aConteudo[nI][nNomeRedu]+ ";"+aConteudo[nI][nEndereco] + ";"+ aConteudo[nI][nEndereco] + ";"+  AllTrim(aConteudo[nI][nEstad]) + ";"+ aConteudo[nI][nCodMun] + ";"+ aConteudo[nI][nMun] +";"+aConteudo[nI][nTipo]+ " <-ERRO"+CRLF )
					Else
						ConfirmSx8()
						MsgInfo("Importado com Sucesso", "Aviso")
						oArquivo:Write(aConteudo[nI][nCod] +";" + PadR(aConteudo[nI][nCod], 6) + ";"+ aConteudo[nI][nNome]+ ";"+aConteudo[nI][nNomeRedu]+ ";"+aConteudo[nI][nEndereco] + ";"+ aConteudo[nI][nEndereco] + ";"+  AllTrim(aConteudo[nI][nEstad]) + ";"+ aConteudo[nI][nCodMun] + ";"+ aConteudo[nI][nMun] +";"+aConteudo[nI][nTipo]+ " <-LINHA ESCRITA COM EXITO!"+CRLF )
					Endif
				Endif
			Next nI
			oArquivo:Close()
		Else
			MsgInfo("Nenhum registro encontrado.", "Aviso")
		Endif

	Endif
Return()


