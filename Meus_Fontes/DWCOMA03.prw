#Include "Protheus.ch"

Static nPosCod    := 1
Static nPosLoja   := 2
Static nPosNome   := 3
Static nPosEnde   := 4
Static nPosNoFant := 5
Static nPosTipo   := 6
Static nPosEstad  := 7
Static nPosMuni   := 8
Static nEscolha   := 9

/*/{Protheus.doc} DWCOMA03
Leitura de CSV
@type function
@author DWC
@since 17/08/2022
/*/

User Function DWCOMA03()
	Local cArquivo  := ""
	Local lContinua := .T.
	Local oArquivo  := Nil
	Local cLinha    := ""
	Local aConteudo := {}
	Local nI        := 0

	Local nRegs     := 0
	Local aClientes := {}

	Private lMsErroAuto := .F.
	Private cTab        := GetNextAlias()/*"SA1"*/

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
			
				cQuery := "SELECT COUNT(A1_COD) REGS" + CRLF
				cQuery += "FROM " + RetSQLName("SA1") + "" + CRLF
				cQuery += "WHERE A1_FILIAL = '" + xFilial("SA1") + "'" + CRLF
				cQuery += "	AND A1_COD = '" + aConteudo[nI][nPosCod] + "'" + CRLF
				cQuery += "	AND A1_LOJA = '" + aConteudo[nI][nPosLoja] + "'" + CRLF
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

				If ((nRegs == 1) .And. (Val(aConteudo[nI][nEscolha]) == 3))
					MsgInfo("Cliente já cadastrado.", "Aviso")
				Else
					If (Val(aConteudo[nI][nEscolha]) == 4 .Or. Val(aConteudo[nI][nEscolha]) == 5)
						DbSelectArea("SA1")
						SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
						SA1->(DbSeek(xFilial("SA1") + PadR(aConteudo[nI][nPosCod], 6) + PadR(aConteudo[nI][nPosLoja], 2)))
					Endif

					aClientes := {{"A1_FILIAL", xFilial("SA1")        , Nil},;
						{"A1_COD"   , PadR(aConteudo[nI][nPosCod], 6) ,	Nil},;
						{"A1_LOJA"  , PadR(aConteudo[nI][nPosLoja], 2),	Nil},;
						{"A1_NOME"  , aConteudo[nI][nPosNome]         ,	Nil},;
						{"A1_END"    , aConteudo[nI][nPosEnde]        ,	Nil},;
						{"A1_NREDUZ", aConteudo[nI][nPosNoFant]       , Nil},;
						{"A1_TIPO"   , aConteudo[nI][nPosTipo]        , Nil},;
						{"A1_EST"  , aConteudo[nI][nPosEstad]         ,	Nil},;
						{"A1_MUN"  , aConteudo[nI][nPosMuni]          ,	Nil}}

					MsExecAuto({|x,y| MATA030(x,y)}, aClientes, Val(aConteudo[nI][nEscolha]))

					If (lMsErroAuto)
						MostraErro()
						RollbackSx8()
					Else
						ConfirmSx8()
						MsgInfo("Cliente incluído com sucesso.", "Aviso")
					Endif
				Endif
			Next nI
		Else
			MsgInfo("Nenhum registro encontrado.", "Aviso")
		Endif
	Endif
Return()


