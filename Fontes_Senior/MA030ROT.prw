#Include "Protheus.ch"

/*/{Protheus.doc} MA030ROT
Ponto de Entrada MA030ROT
@type function
@author Gabriel Marques
@since 15/08/2022
/*/

User Function MA030ROT()
    Local aRet := {}

    aAdd(aRet, {"Lista de Clientes", "U_DWCOMR02", 0, 2, 0, Nil})
    aAdd(aRet, {"Incluir Clientes", "U_DWCOMA30", 0, 2, 0, Nil})
    
Return(aRet)

