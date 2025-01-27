#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 28/07/2019
@Hora: 11:07:02
@Versão: 1.0
@Uso: 
@Descrição: 
---------------------------------------------
Change:
--------------------------------------------*/
User Function FTVD7001()

	Local lRet := .F.
	
		U_VAEDANFE()
		if MsgYesNo("Confirma a finalização da Venda?","Atenção")
			lRet := .T.
		endif
	
Return(lRet)