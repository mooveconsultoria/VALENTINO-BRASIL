#INCLUDE "rwmake.ch"

User Function M020INC()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M020INC  º Autor ³ VITOR LUIS FATTORI º Data ³  29/01/04    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de Entrada p/ para geracao automatica da Conta Conta-º±±
±±º          ³ bil do Fornecedor conforme inclusao do mesmo.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cadastro de Fornecedores                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºAlterações³ 18/12/2004 Donizete/Microsiga.                             º±±
±±º          ³ Atualizado para versão MP 8 e alterado lógica.             º±±
±±º          ³ 21/02/2005 Donizete/Microsiga.                             º±±
±±º          ³ Adaptado para Cliente TREBOL.                              º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

// Declaração das Variáveis.
Local _xAreaSA2		:= {}
Local _xAreaCT1		:= {}
Local _cNome		:= ""
Local _cCod			:= ""
Local _cEst			:= ""
Local _cConta		:= ""
Local _mContab		:= Upper(Alltrim(GetMv("MV_MCONTAB")))

// Processa somente se o módulo for SIGACTB e a opção for de Inclusão.
If INCLUI .and. _mContab == "CTB"
	
	dbSelectArea("SA2")
	_xAreaSA2 := GetArea()
	
	// Memoriza dados.
	_cNome		:= SA2->A2_NOME
	_cCod		:= SA2->A2_COD+SA2->A2_LOJA
	_cEst		:= SA2->A2_EST
	_cConta  	:= ""
	
	Do case
		Case SubStr(_cCod,1,1)$ "0123456" // Fornecedores Nacionais
			_cConta:="21020101"
		Case SubStr(_cCod,1,1)=="E" // Fornecedores Estrangeiros
			_cConta:="21020102"
		OtherWise // Não cria a conta.
			Return
	EndCase
	
	dbSelectArea("CT1")
	_xAreaCT1 := GetArea()
	dbSetOrder(1)
	DbSeek(xFilial("CT1") + _cConta + SA2->A2_COD + SA2->A2_LOJA)
	If .not. Found()
		Begin Transaction
		// Cria a conta no plano de contas.
		If Reclock("CT1", .T.)
			REPLACE CT1->CT1_FILIAL	with xFilial("CT1")
			REPLACE CT1->CT1_CONTA	with _cConta + _cCod
			REPLACE CT1->CT1_DESC01 with _cNome
			REPLACE CT1->CT1_DESC02 with _cNome
			REPLACE CT1->CT1_DESC03 with ""
			REPLACE CT1->CT1_DESC04 with ""
			REPLACE CT1->CT1_DESC05 with _cNome
			REPLACE CT1->CT1_CLASSE with "2"
			REPLACE CT1->CT1_NORMAL with "1"
			REPLACE CT1->CT1_RES    with _cCod
			REPLACE CT1->CT1_BLOQ	with "2"
			REPLACE CT1->CT1_DTBLIN	with Ctod(Space(8))
			REPLACE CT1->CT1_DTBLFI	with Ctod(Space(8))
			REPLACE CT1->CT1_DC  	with "1"
			REPLACE CT1->CT1_NCUSTO with 0
			REPLACE CT1->CT1_CC  	with ""
			REPLACE CT1->CT1_CVD02	with "1"
			REPLACE CT1->CT1_CVC02	with "1"
			REPLACE CT1->CT1_CVD03	with "1"
			REPLACE CT1->CT1_CVC03	with "1"
			REPLACE CT1->CT1_CVD04	with "1"
			REPLACE CT1->CT1_CVC04	with "1"
			REPLACE CT1->CT1_CVD05	with "1"
			REPLACE CT1->CT1_CVC05	with "1"
			REPLACE CT1->CT1_CTASUP	with _cConta
			REPLACE CT1->CT1_HP    	with ""
			REPLACE CT1->CT1_ACITEM	with "2"
			REPLACE CT1->CT1_ACCUST	with "2"
			REPLACE CT1->CT1_ACCLVL	with "2"
			REPLACE CT1->CT1_DTEXIS	with CTOD("01/01/1980")
			REPLACE CT1->CT1_CTAVM	with ""
			REPLACE CT1->CT1_CTARED	with ""
			REPLACE CT1->CT1_CTALP	with ""
			REPLACE CT1->CT1_CTAPON	with ""
			REPLACE CT1->CT1_BOOK	with "001/002/003/004/005"
			REPLACE CT1->CT1_GRUPO  with ""
			REPLACE CT1->CT1_AGLSLD	with "2"
			REPLACE CT1->CT1_RGNV1	with "*"
			REPLACE CT1->CT1_RGNV2	with ""
			REPLACE CT1->CT1_RGNV3	with ""
			REPLACE CT1->CT1_CCOBRG	with "2"
			REPLACE CT1->CT1_ITOBRG	with "2"
			REPLACE CT1->CT1_CLOBRG	with "2"
			REPLACE CT1->CT1_LALUR	with "2"
			REPLACE CT1->CT1_RATEIO	with ""
			REPLACE CT1->CT1_AGLUT	with ""
			REPLACE CT1->CT1_TRNSEF	with ""
			REPLACE CT1->CT1_CTLALU	with ""
			REPLACE CT1->CT1_ESTOUR	with ""
			REPLACE CT1->CT1_CODIMP	with ""
			REPLACE CT1->CT1_AJ_INF	with ""
			MsUnlock()
		EndIf
		
		// Atualiza a conta no cadastro do Fornecedor.
		DbSelectArea("SA2")
		If Reclock("SA2", .F.)
			REPLACE SA2->A2_CONTA	with _cConta + _cCod
			MsUnlock()
		EndIf
		
		END TRANSACTION
	Endif
	
	// Restaura áreas de trabalho.
	DbSelectArea("CT1")
	RestArea(_xAreaCT1)
	DbSelectArea("SA2")
	RestArea(_xAreaSA2)
	
Endif

Return
