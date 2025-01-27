#Include 'Protheus.ch'

/*/{Protheus.doc}  MT103COR
Legenda(Branca) Documento de Entrada.
"Conferida"

@author Eduardo Patriani
@since 16/05/2019
@version 1.0

/*/
User Function MT103COR()
	Local aCor	:= aClone(ParamIxb[1])
	Local aCoresUsr := {}
	Local nX

	aadd(aCoresUsr,{'Empty(F1_STATUS) .AND. F1_XCONF == "S"' , 'BR_BRANCO'})
	aadd(aCoresUsr,{'Empty(F1_STATUS) .AND. F1_XCONF == "N"' , 'BR_PRETO'})

	For nX := 1 to Len(aCor)
		aadd(aCoresUsr,{aCor[nX][1], aCor[nX][2]})
	next nX

Return(aCoresUsr)