#include 'protheus.ch'
#include 'parmtype.ch'
/******************************************************************************
* Ponto de entrada para preencher automaticamente o codigo da obrigacao       *
* Oscar Lira        21/11/2022                                                *
* Paramixb[1] => Tipo GNRE                                                    *
* Paramixb[2] => ESTADO da GNRE                                               *
******************************************************************************/
User function SPCOBREC()
Local cTipoImp := Paramixb[1] // Tipo de Imposto (3 - ICMS ST ou B - Difal e Fecp de Difal)
Local cEstado := Paramixb[2] // Estado da GNRE
Local cCod := "" // Codigo a ser gravado no campo F6_COBREC

If cTipoImp == "B"
    If SF6->F6_FECP = "1"
        cCod := "006"
    Else
        cCod := "000"
    EndIf
/*Else 
    cCod := "999"  */
EndIf

Return cCod
