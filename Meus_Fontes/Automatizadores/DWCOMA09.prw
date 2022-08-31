
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

User Function DWCOMA09()
	Local cArquivo  := ""
	Local cLinha    := ""
	Local lContinua := .T.
	Local aConteudo := {}
	Local aPedidos := {}
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

				cQuery := "SELECT C7_NUMSC"+ CRLF
				cQuery += ",C7_FORNECE" + CRLF
				cQuery += ",C7_LOJA   " + CRLF
				cQuery += ",C7_COND   " + CRLF
				cQuery += ",C7_ITEM   " + CRLF
				cQuery += ",C7_PRODUTO" + CRLF
				cQuery += ",C7_QUANT  " + CRLF
				cQuery += ",C7_PRECO  " + CRLF
				cQuery += ",C7_TOTAL FROM " + RetSQLName("SC7") + CRLF
				cQuery += "WHERE D_E_L_E_T_= ''"+ CRLF
				MPSysOpenQuery(cQuery, cTab)

				DbSelectArea((cTab))
				(cTab)->(DbGoTop())

				While ((cTab)->(!Eof()))

					(cTab)->(DbSkip())
				ENDDO

				(cTab)->(DbCloseArea())

					aPedidos := {{"C7_NUMSC", aConteudo[nI][nNum] ,	Nil},;
						{"C7_FORNECE"   ,  			aConteudo[nI][nForn],	Nil},;
						{"C7_LOJA" ,     			  aConteudo[nI][nLoja],	Nil},;
						{"C7_COND" ,      		  aConteudo[nI][nCondPag],Nil},;
						{"C7_PRODUTO",			    aConteudo[nI][nProd],Nil},;
						{"C7_QUANT", 			 			aConteudo[nI][nQntd],Nil},;
						{"C7_PRECO",   			    aConteudo[nI][nPreco] ,Nil}}

					MsExecAuto({|x,y| MATA121(x,y)}, aPedidos, Val(aConteudo[nI][nOpc]),.F.)

					If (lMsErroAuto)
						MsgInfo("Erro na Importação", "Aviso")
						oArquivo:Write(aConteudo[nI][nNum] +";" + (aConteudo[nI][nForn]) + ";"+ aConteudo[nI][nLoja]+ ";"+aConteudo[nI][nCondPag]+ ";"+aConteudo[nI][nProd] + ";"+ aConteudo[nI][nQntd] + ";"+  (aConteudo[nI][nPreco])+ " <-ERRO"+CRLF )
					Else
						ConfirmSx8()
						MsgInfo("Importado com Sucesso", "Aviso")
						oArquivo:Write(aConteudo[nI][nNum] +";" + (aConteudo[nI][nForn]) + ";"+ aConteudo[nI][nLoja]+ ";"+aConteudo[nI][nCondPag]+ ";"+aConteudo[nI][nProd] + ";"+ aConteudo[nI][nQntd] + ";"+  (aConteudo[nI][nPreco])+" <-LINHA ESCRITA COM EXITO!"+CRLF )
					Endif

			Next nI
			oArquivo:Close()

		Else
			MsgInfo("Nenhum registro encontrado.", "Aviso")
		Endif

	Endif
Return()


