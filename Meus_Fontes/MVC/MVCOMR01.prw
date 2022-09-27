#INCLUDE "Protheus.ch"

/*/{Protheus.doc} MVCOMA01
Relatorio de Pre Pedido 
@type function
@author Gabriel Marques
@since 11/06/2021
/*/

User Function MVCOMR01()

	Local oReport := Nil
	Private cTab := GetNextAlias()
	oReport := ReportDef(cTab)
	oReport:PrintDialog()
Return()

Static Function ReportDef(cTab)


	Local oReport   := Nil
	Local oSection1 := Nil
	Local oSection2 := Nil

	oReport := TReport():New("MVCOMR01", "Lista de Pré Pedidos","MVCOMR01", {|oReport| ReportPrint(oReport)}, "Imprime lista de pré pedidos.")

	oReport:SetPortrait()

	oSection1 := TRSection():New(oReport)
	TRCell():New(oSection1, "Z1_CODIGO"   , , "Codigo"   , /*cPicture*/, TamSX3("Z1_CODIGO")[1]   , /*lPixel*/, {||(cTab) ->Z1_CODIGO}) //Criar as colunas que vÃ£o aparecer no relatÃ³rio
	TRCell():New(oSection1, "Z1_TIPOPED"   , , "Tipo"   , /*cPicture*/, TamSX3("Z1_TIPOPED")[1]   , /*lPixel*/,{||(cTab) ->Z1_TIPOPED})
	TRCell():New(oSection1, "Z1_CLIENTE"   , , "Cliente"   , /*cPicture*/, TamSX3("Z1_CLIENTE")[1]   , /*lPixel*/, {||(cTab) ->Z1_CLIENTE})
	TRCell():New(oSection1, "A1_NOME"   , , "Nome do Cliente"   , /*cPicture*/, TamSX3("A1_NOME")[1]   , /*lPixel*/, {||(SA1->A1_NOME)})
	TRCell():New(oSection1, "Z1_LOJACLI" , ,"Loja"   , /*cPictur*/, TamSX3("Z1_LOJACLI")[1]   , /*lPixel*/, {||(cTab) ->Z1_LOJACLI})
	TRCell():New(oSection1, "Z1_CONDPAG"	, , "Condição de Pagamento"	, /*cPicture*/, TamSX3("Z1_CONDPAG")[1]   , /*lPixel*/,{||(cTab) ->Z1_CONDPAG})
	TRCell():New(oSection1, "E4_DESCRI"	, , "Descrição Cond.Pag"	, /*cPicture*/, TamSX3("E4_DESCRI")[1]   , /*lPixel*/,{||SE4->E4_DESCRI})


	oSection2 := TRSection():New(oReport)
	TRCell():New(oSection2, "Z2_ITEM", , "Item"	, /*cPicture*/, TamSX3("Z2_ITEM")[1]   , /*lPixel*/,{||(cTab) ->Z2_ITEM})
	TRCell():New(oSection2, "Z2_PRODUTO"	, , "Produto"	, /*cPicture*/, TamSX3("Z2_PRODUTO")[1]   , /*lPixel*/,{||(cTab) ->Z2_PRODUTO})
	TRCell():New(oSection2, "SZ2990.B1_DESC"	, , "Descrição Prod"	, /*cPicture*/, TamSX3("B1_DESC")[1]   , /*lPixel*/,{||(SB1->B1_DESC)})
	TRCell():New(oSection2, "Z2_QTDVEN", , "Quantidade"	, /*cPicture*/, TamSX3("Z2_QTDVEN")[1]   , /*lPixel*/,{||(cTab) ->Z2_QTDVEN})
	TRCell():New(oSection2, "Z2_PRCVEN"	, , "Valor"	, /*cPicture*/, TamSX3("Z2_PRCVEN")[1]  , /*lPixel*/,{||(cTab) ->Z2_PRCVEN})
	TRCell():New(oSection2, "Z2_TES", , "TES"	, /*cPicture*/, TamSX3("Z2_TES")[1]+3   , /*lPixel*/,{||(cTab) -> Z2_TES})
	TRCell():New(oSection2, "F4_FINALID", , "Descrição TES"	, /*cPicture*/, TamSX3("F4_FINALID")[1]   , /*lPixel*/,{||SF4-> F4_FINALID})

	//oBreak1 := TRBreak():New(oSection2, {|| cNat}, )
//	TRFunction():New(oSection2:Cell("Z2_QTDVEN"), , "SUM", oBreak1, /**/, /*cPicture*/, , .T./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/, /*oParent*/, /*bCondition*/, /*lDisable*/, /*bCanPrint*/)
//	TRFunction():New(oSection2:Cell("Z2_PRCVEN"), , "SUM", oBreak1, /**/, /*cPicture*/, , .T./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/, /*oParent*/, /*bCondition*/, /*lDisable*/, /*bCanPrint*/)

Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := Nil
	Local oSection2 := Nil
	Local nRegs     := 0
	Local nCont     := 0
	Local cQuery := ""
	Default oReport := Nil

cQuery +="SELECT DISTINCT Z1_CODIGO,"+ CRLF
cQuery +="Z1_FILIAL, "+ CRLF
cQuery +="Z1_TIPO,   "+ CRLF
cQuery +="Z1_CLIENTE,"+ CRLF
cQuery +="Z1_LOJACLI,"+ CRLF
cQuery +="Z1_TIPOPED,"+ CRLF
cQuery +="Z1_CONDPAG,"+ CRLF
cQuery +="Z2_FILIAL, "+ CRLF
cQuery +="Z2_ITEM,   "+ CRLF
cQuery +="Z2_PRODUTO,"+ CRLF
cQuery +="Z2_QTDVEN, "+ CRLF
cQuery +="Z2_PRCVEN, "+ CRLF
cQuery +="Z2_TES,    "+ CRLF
cQuery +="A1_NOME,   "+ CRLF
cQuery +="B1_DESC,   "+ CRLF
cQuery +="E4_DESCRI, "+ CRLF
cQuery +="F4_FINALID FROM "+ RetSQLName("SZ1")+ " INNER JOIN "+RetSQLName("SZ2")+" ON SZ1990.Z1_CODIGO = SZ2990.Z2_CODIGO"+ CRLF
cQuery +="INNER JOIN "+RetSQLName("SA1")+" ON SZ1990.Z1_CLIENTE = SA1990.A1_COD"+ CRLF
cQuery +="INNER JOIN "+RetSQLName("SE4")+" ON SZ1990.Z1_CONDPAG = SE4990.E4_CODIGO"+ CRLF
cQuery +="INNER JOIN "+RetSQLName("SB1")+" ON SZ2990.Z2_PRODUTO = SB1990.B1_COD"+ CRLF
cQuery +="INNER JOIN "+RetSQLName("SF4")+" ON SZ2990.Z2_TES = SF4990.F4_CODIGO"+ CRLF
cQuery +="WHERE SZ1990.D_E_L_E_T_ = '' AND SZ2990.D_E_L_E_T_ = '' AND Z1_FILIAL ="+ xFilial("SZ1")+" AND Z2_FILIAL ="+ xFilial("SZ2")+ CRLF
cQuery +="ORDER BY Z1_CODIGO ASC"+ CRLF

	MPSysOpenQuery(cQuery, (cTab))
	DbSelectArea(cTab)

	Count To nRegs
	(cTab)->(DbGoTop())

	
	If (!Empty(nRegs))
		oReport:SetMeter(nRegs)

		cNat := (cTab)->Z1_CODIGO

		oSection1 := oReport:Section(1)
		oSection2 := oReport:Section(2)

		oSection1:Init()
		oSection2:Init()

		oSection1:PrintLine()
	Endif

	While ((cTab)->(!Eof()))
		nCont++
		oReport:IncMeter()


		If (cNat <> (cTab)->Z1_CODIGO)//
			oSection2:Finish()
			oSection1:Finish()

			oSection1:Init()
			

			oSection1:PrintLine()

			oSection2:Init()
			cNat := (cTab)->Z1_CODIGO
		Endif
		oSection2:PrintLine()

		If (nCont == nRegs)
			oSection1:Finish()
			oSection2:Finish()

			oReport:EndPage()
		Endif

		(cTab)->(DbSkip())
	Enddo

	(cTab)->(DbCloseArea())
Return()
