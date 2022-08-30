//Importaçao de Fornecedores 
#INCLUDE "Protheus.ch"
Static nCod   := 1
Static nLoja  := 2
Static nNome   := 3
Static nNomeRedu   := 4
Static nEndereco := 5
Static nEstad   := 6
Static nCodMun  := 7
Static nMun  := 8
Static nTipo :=9
Static nEscolha   := 10
//Static nErro   := 11


/*/{Protheus.doc} DWCOMA03
Leitura de CSV - Fornecedores
@type function
@author Gabriel Marques
@since 26/08/2022
/*/

User Function DWCOMA07()
	Local cArquivo  := ""
	Local lContinua := .T.
	Local oArquivo  := Nil
	Local cLinha    := ""
	Local aConteudo := {}
	Local nI        := 0
//	Local nHandle := 0

	Local nRegs     := 0
	Local aFornecedor := {}

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
			For nI := 1 To Len(aConteudo)

				cQuery := "SELECT COUNT(A2_COD) REGS" + CRLF
				cQuery += "FROM " + RetSQLName("SA2") + "" + CRLF
				cQuery += "	WHERE A2_COD = '" + aConteudo[nI][nCod] + "'" + CRLF
				cQuery += "	AND A2_LOJA = '" + aConteudo[nI][nLoja] + "'" + CRLF
				cQuery += "	AND D_E_L_E_T_ = ''" + CRLF
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
					MsgInfo("Fornecedor já cadastrado.", "Aviso")
				Else
					If (Val(aConteudo[nI][nEscolha]) == 4 .Or. Val(aConteudo[nI][nEscolha]) == 5)
						DbSelectArea("SA2")
						SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
						SA1->(DbSeek(xFilial("SA2") + PadR(aConteudo[nI][nCod], 6) + PadR(aConteudo[nI][nLoja], 2)))
					Endif

					aFornecedor := {{"A2_COD"   , PadR(aConteudo[nI][nCod], 6) ,	Nil},;
						{"A2_LOJA"   , PadR(aConteudo[nI][nLoja],2),	Nil},;
						{"A2_NOME"   , aConteudo[nI][nNome],	Nil},;
						{"A2_NREDUZ" , aConteudo[nI][nNomeRedu],Nil},;
						{"A2_END"    , aConteudo[nI][nEndereco],Nil},;
						{"A2_EST"    , AllTrim(aConteudo[nI][nEstad]),Nil},;
						{"A2_COD_MUN", aConteudo[nI][nCodMun],Nil},;
						{"A2_MUN"		 , aConteudo[nI][nMun] ,Nil},;
						{"A2_TIPO"   , aConteudo[nI][nTipo],Nil}}

					MsExecAuto({|x,y| MATA020(x,y)}, aFornecedor, Val(aConteudo[nI][nEscolha]))

					If (lMsErroAuto)

						oArquivo:= FWFileWriter():New("C:\TOTVS12\Workspace\Exemplos\Exercicio_01\Arquivos", .T.)
							//oArquivo:Write((CLINHA :=CLINHA+"<-ERRO"))		
							CLINHA:Write("<-ERRO")		
						oArquivo:Close()
	
						MsgInfo("Erro na Importação", "Aviso")
					Else
						ConfirmSx8()
						MsgInfo("Importado com Sucesso", "Aviso")

					Endif
				Endif
			Next nI
		Else
			MsgInfo("Nenhum registro encontrado.", "Aviso")
		Endif

	Endif
Return()


