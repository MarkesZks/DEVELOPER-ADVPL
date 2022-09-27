#INCLUDE "Protheus.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

/*/{Protheus.doc} TestRest01
  (Test REST)
  @type  Function
  @author Gabriel Marques
  @since 26/09/2022
  /*/
 user Function TestRest01()
  
private oRest := FWRest():New("httpbin.org/")
private aHeader :={}

oRest:setPath("colocamos a rotaaqui")

if oRest:Get(aHeader) // Pode ser GET POST DELETE 
ConOut("GET",oRest:GetResult())
else
ConOut("GET",oRest:GetLastError())

  ENDIF
Private resultado := oRest:GetResult()
Private erro := oRest:GetLastError()
MsgAlert(resultado)
MsgAlert(erro)
ConOut("Fim")

Return 

