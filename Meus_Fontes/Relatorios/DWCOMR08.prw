#INCLUDE "Protheus.ch"

/*/{Protheus.doc} DWCOMR08
Relatorio Pedido de compra 
@type function
@author Gm
@since 30/08/2022
/*/
User Function DWCOMR08()

	Local oReport := Nil
	Private cTab := GetNextAlias()
	oReport := ReportDef(cTab)
	oReport:PrintDialog()
Return()

Static Function ReportDef(cTab)

	Local oReport   := Nil
	Local oSection1 := Nil
	Local oSection2 := Nil

	oReport := TReport():New("DWCOMR08", "Lista de Pedido de compra ","DWCOMR08", {|oReport| ReportPrint(oReport)}, "Imprime lista de Pedido de compra .")

	oReport:SetPortrait()

	oSection1 := TRSection():New(oReport)
	TRCell():New(oSection1, "C7_NUM"   , , "Numero do PC"   , /*cPicture*/, TamSX3("C7_NUM")[1]   , /*lPixel*/, {||(cTab) ->C7_NUM})
	TRCell():New(oSection1, "C7_EMISSAO"   , , "Data de Emissao"   , /*cPicture*/, TamSX3("C7_EMISSAO")[1]   , /*lPixel*/,{||(cTab) ->C7_EMISSAO})
	TRCell():New(oSection1, "C7_FORNECE"   , , "Fornecedor"   , /*cPicture*/, TamSX3("C7_FORNECE")[1]   , /*lPixel*/, {||(cTab) ->C7_FORNECE})
	TRCell():New(oSection1, "C7_LOJA"   , , "Loja"   , /*cPicture*/, TamSX3("C7_LOJA")[1]   , /*lPixel*/, {||(cTab) ->C7_LOJA})
	TRCell():New(oSection1, "C7_COND"   , , "Condicao de Pag"   , /*cPicture*/, TamSX3("C7_COND")[1]   , /*lPixel*/, {||(cTab) ->C7_COND})
	TRCell():New(oSection1, "C7_FILENT"   , , "Filial para Entrega "   , /*cPicture*/, TamSX3("C7_FILENT")[1]   , /*lPixel*/, {||(cTab) ->C7_FILENT})


	oBreak1 := TRBreak():New(oSection1, {|| cNat}, )
	TRFunction():New(oSection1:Cell("C7_NUM"), /*cID*/, "Numero do PC", oBreak1, /**/, /*cPicture*/, , .F./*lEndSection*/, .F./*lEndReport*/, .F./*lEndPage*/, /*oParent*/, /*bCondition*/, /*lDisable*/, /*bCanPrint*/)


	oSection2 := TRSection():New(oReport)
	TRCell():New(oSection2, "C7_PRODUTO", , "Codigo do Produto"	, /*cPicture*/, TamSX3("C7_PRODUTO")[1]  , /*lPixel*/,{||(cTab) ->C7_PRODUTO})
	TRCell():New(oSection2, "C7_QUANT"	, , "Quantidade"	, /*cPicture*/, TamSX3("C7_QUANT")[1]   , /*lPixel*/,{||(cTab) ->C7_QUANT})
	TRCell():New(oSection2, "C7_PRECO", , "Preço Uni"	, /*cPicture*/, TamSX3("C7_PRECO")[1]   , /*lPixel*/,{||(cTab) ->C7_PRECO})
	TRCell():New(oSection2, "C7_TOTAL", , "Preço Total"	, /*cPicture*/, TamSX3("C7_TOTAL")[1]   , /*lPixel*/,{||(cTab) ->C7_TOTAL})



Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := Nil
	Local oSection2 := Nil
	Local nRegs     := 0
	Local nCont     := 0
	Local cQuery := ""

	Default oReport := Nil

	cQuery := "SELECT C7_NUM"+ CRLF
	cQuery += ",C7_EMISSAO" + CRLF
	cQuery += ",C7_FORNECE" + CRLF
	cQuery += ",C7_LOJA   " + CRLF
	cQuery += ",C7_COND   " + CRLF
	cQuery += ",C7_FILENT   " + CRLF
	cQuery += ",C7_PRODUTO" + CRLF
	cQuery += ",C7_QUANT  " + CRLF
	cQuery += ",C7_PRECO  " + CRLF
	cQuery += ",C7_TOTAL FROM " + RetSQLName("SC7") + CRLF
	cQuery += "WHERE D_E_L_E_T_= ''"+ CRLF
	cQuery += "ORDER BY C7_NUM ASC "+ CRLF

	MPSysOpenQuery(cQuery, (cTab))
	DbSelectArea(cTab)

	Count To nRegs
	(cTab)->(DbGoTop())

	If (!Empty(nRegs))
		oReport:SetMeter(nRegs)

		cNat := (cTab)->C7_NUM

		oSection1 := oReport:Section(1)
		oSection2 := oReport:Section(2)

		oSection1:Init()
		oSection2:Init()

		oSection1:PrintLine()
	Endif

	While ((cTab)->(!Eof()))
		nCont++
		oReport:IncMeter()


		If (cNat <> (cTab)->C7_NUM)//
			oSection2:Finish()
			oSection1:Finish()

			oSection1:Init()

			oSection1:PrintLine()

			oSection2:Init()
			cNat := (cTab)->C7_NUM
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
