//Relatorio de Fornecedores 
#INCLUDE "Protheus.ch"

User Function DWCOMR06()

	Local oReport := Nil
	Private cTab := GetNextAlias()

	oReport := ReportDef(cTab)
	oReport:PrintDialog()
Return()

Static Function ReportDef(cTab)

	Local oReport   := Nil
	Local oSection1 := Nil

	oReport := TReport():New("DWCOMR06", "Lista de Fornecedores","DWCOMR06", {|oReport| ReportPrint(oReport)}, "Imprime lista de Forecedores.")
	oReport:SetPortrait()

	oSection1 := TRSection():New(oReport)
	TRCell():New(oSection1, "A2_COD"   , , "Codigo"   , /*cPicture*/, TamSX3("A2_COD")[1]   , /*lPixel*/, {||(cTab) ->A2_COD}) //Criar as colunas que vão aparecer no relatório
	TRCell():New(oSection1, "A2_LOJA"   , , "Loja"   , /*cPicture*/, TamSX3("A2_LOJA")[1]   , /*lPixel*/,{||(cTab) ->A2_LOJA})
	TRCell():New(oSection1, "A2_NOME"   , , "Razao Social"   , /*cPicture*/, TamSX3("A2_NOME")[1]   , /*lPixel*/, {||(cTab) ->A2_NOME})
	TRCell():New(oSection1, "A2_NREDUZ" , ,"Nome Fantasia"   , /*cPictur*/, TamSX3("A2_NREDUZ")[1]   , /*lPixel*/,{||(cTab) ->A2_NREDUZ})
	TRCell():New(oSection1, "A2_END"   , , "Endereco"   , /*cPicture*/, TamSX3("A2_END")[1]   , /*lPixel*/,{||(cTab) ->A2_END})
	TRCell():New(oSection1, "A2_EST"	, , "Estado"	, /*cPicture*/, TamSX3("A2_EST")[1]   , /*lPixel*/,{||(cTab) ->A2_EST})
	TRCell():New(oSection1, "A2_MUN"	, , "Municipio"	, /*cPicture*/, TamSX3("A2_MUN")[1]   , /*lPixel*/,{||(cTab) ->A2_MUN})
	TRCell():New(oSection1, "A2_TIPO"	, , "Tipo"	, /*cPicture*/, TamSX3("A2_TIPO")[1]   , /*lPixel*/,{||(cTab) ->A2_TIPO})


Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := Nil
	Local nRegs     := 0
	Local nCont     := 0
	Local cQuery := ""

	Default oReport := Nil
	cQuery +="SELECT A2_COD"+ CRLF
	cQuery +=",A2_LOJA"+ CRLF
	cQuery +=",A2_NOME"+ CRLF
	cQuery +=",A2_NREDUZ"+ CRLF
	cQuery +=",A2_END"+ CRLF
	cQuery +=",A2_EST"+ CRLF
	cQuery +=",A2_MUN"+ CRLF
	cQuery +=",A2_TIPO FROM "+ RetSQLName("SA2")+ CRLF
	cQuery +="WHERE D_E_L_E_T_ = ''"+ CRLF
	MPSysOpenQuery(cQuery, (cTab))
	DbSelectArea(cTab)

	Count To nRegs
	(cTab)->(DbGoTop())

	If (!Empty(nRegs))
		oReport:SetMeter(nRegs)
		oSection1 := oReport:Section(1)
		oSection1:Init()
	Endif

	While ((cTab)->(!Eof()))
		nCont++
		oReport:IncMeter()

		oSection1:PrintLine()

		If (nCont == nRegs)
			oSection1:Finish()

			oReport:EndPage()
		Endif

		(cTab)->(DbSkip())
	Enddo

	(cTab)->(DbCloseArea())
Return()
