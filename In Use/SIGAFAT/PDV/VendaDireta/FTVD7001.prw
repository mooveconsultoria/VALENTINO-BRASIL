#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 28/07/2019
@Hora: 11:07:02
@Vers�o: 1.0
@Uso: 
@Descri��o: 
---------------------------------------------
Change:
--------------------------------------------*/
User Function FTVD7001()

	Local lRet := .F.
	
		U_VAEDANFE()
		if MsgYesNo("Confirma a finaliza��o da Venda?","Aten��o")
			lRet := .T.
		endif
	
Return(lRet)