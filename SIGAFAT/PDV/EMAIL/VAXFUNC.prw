#Include "Protheus.ch"
#INCLUDE 'AP5MAIL.CH'
#INCLUDE 'TOPCONN.CH'

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 24/06/2019
@Hora: 16:26:51
@Versão: 1.0
@Uso: VALENTINO
@Descrição: Envia e-mail aos responsaveis
indicados nos parameros especpficos.
--------------------------------------------*/
User Function FUN_EMAIL(_cAttach,cAssunto,cMensagem,cEmailTo,cEmailCc,cEmailBcc)

Local lOk		:= .F.								// Variavel que verifica se foi conectado OK
Local lSendOk	:= .F.								// Variavel que verifica se foi enviado OK
Local cError	:= ''
Local lMailAuth	:= SuperGetMV('MV_RELAUTH',,.T.)
Local cMailAuth := ''
Local lResult	:= .F.
Local cAtuDir 	:= ''

Private _fTt0       := 'Atenção.'
Private _fTt1       := 'Específico VALENTINO - Programa: ' + Alltrim(FunName())
Private _fCx0       := 'INFO'
Private _fCx1       := 'STOP'
Private _fCx2       := 'OK'
Private _fCx3       := 'ALERT'
Private _fCx4       := 'YESNO'

Private nTimeOut    := SuperGetMV('MV_RELTIME',,120) 					// Tempo de Espera antes de abortar a Conexao
Private cMailServer	:= SuperGetMV('MV_RELSERV',.F.,"smtp.google.com:587")
Private cMailConta	:= SuperGetMV('MV_RELACNT',.F.,"protheus.valentino@gmail.com")
Private cMailSenha	:= SuperGetMV('MV_RELPSW',.F.,"njllgrqrihxwvnpq")

//cMailServer	    := "smtp.outlook.com:587 "
//cMailConta		:= "pamela.sallas@dga.com.br"
//cMailSenha		:= "Pa1035la"

// chamado #43215 Alteração de dados de conexão

//cMailServer	    := "smtp.google.com:587"
//cMailConta		:= "protheus.valentino@gmail.com"
//cMailSenha		:= "Omegadga@19"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe o SMTP Server.                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cMailServer)
	_fMg0		:= 'O Servidor de SMTP nao foi configurado!' + CRLF + CRLF
	MsgBox(_fMg0,_fTt1,_fCx1)
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe a CONTA.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cMailConta)
	_fMg0		:= 'A Conta do email nao foi configurada!' + CRLF + CRLF
	MsgBox(_fMg0,_fTt1,_fCx1)
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe a Senha.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cMailSenha)
	_fMg0		:= 'A Senha do email nao foi configurada!' + CRLF + CRLF
	MsgBox(_fMg0,_fTt1,_fCx1)
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty (AllTrim(cAtuDir := GetPvProfString(GetEnvServer(),'StartPath','',GetADV97())))
	If !(Subst(cAtuDir,1,1) $ '\/' )
		cAtuDir := '\'+cAtuDir
	EndIf
	If !(Subst(cAtuDir,-1) $ '\/' )
		cAtuDir += '\'
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia e-mail com os dados necessarios.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)
	
	CONNECT SMTP SERVER CMAILSERVER ACCOUNT CMAILCONTA PASSWORD CMAILSENHA RESULT lOk
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a autenticacao no servidor SMTP.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( lMailAuth )
		lResult := MailAuth(cMailConta,cMailSenha)
	Else
		lResult := .T.
	EndIf
	
	If 	lOk .And. lResult
		_fMg0 := "Enviando email para "+cEmailTo+CRLF
		_fMg0 += "com copia para "+cEmailCc+CRLF
		_fMg0 += "com copia oculta para "+cEmailBCc+CRLF
		ConOut(_fMg0)

		//SEND MAIL FROM cMailConta TO cEmailTo CC cEmailCc BCC cEmailBcc SUBJECT cAssunto BODY cMensagem ATTACHMENT _cAttach RESULT lSendOk
		SEnd Mail From cMAILCONTA to cEmailTo CC cEmailCc BCC cEmailBcc SubJect cASSUNTO BODY cMensagem FORMAT TEXT ATTACHMENT _cAttach RESULT lSendOk
		
		If !lSendOk
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Erro no Envio do e-mail.                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			GET MAIL ERROR cError
			_fMg0		:= 'Erro no envio do e-mail.'	+ CRLF + CRLF
			_fMg0		+= cError + CRLF
			_fMg0		+= 'Favor verificar!' 								+ CRLF
			MsgStop(_fMg0,_fTt1,_fCx1)
			
			Return(.F.)
		EndIf
		
		DisConnect Smtp Server Result lDesconexao
		
		If !lDesconexao
			Get Mail Error cErro_Desconexao
			MsgStop("Nao foi possivel DESCONECTAR do servidor - " + cErro_Desconexao )

			Return( .F. )
		EndIf		
	Else
		//³ Erro na conexao com o SMTP Server.                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GET MAIL ERROR cError
		_fMg0		:= 'Erro na conexao com o servidor de e-mails ou na autenticação da conta.' + CRLF + CRLF
		_fMg0		+= cError + CRLF
		_fMg0		+= 'Favor verificar!' 														+ CRLF
		MsgStop(_fMg0,_fTt1,_fCx1)
		Return(.F.)
	EndIf
EndIf

Return(.T.)

/*/{Protheus.doc} MyNewSX6
//TODO Descrição auto-gerada.
@author Lucas
@since 21/09/2017

@param cMvPar, characters, descricao
@param xValor, , descricao
@param cTipo, characters, descricao
@param cDescP, characters, descricao
@param cDescS, characters, descricao
@param cDescE, characters, descricao
@param lAlter, logical, descricao

@type function
/*/
User Function MyNewSX6( cMvPar, xValor, cTipo, cDescP, cDescS, cDescE, lAlter )

Local aAreaAtu	:= GetArea()
Local lRecLock	:= .F.
Local xlReturn

Default lAlter := .F.

If ( ValType( xValor ) == "D" )
	If " $ xValor
		xValor := Dtoc( xValor, "ddmmyy" )
	Else
		xValor	:= Dtos( xValor )
	Endif
ElseIf ( ValType( xValor ) == "N" )
	xValor	:= AllTrim( Str( xValor ) )
ElseIf ( ValType( xValor ) == "L" )
	xValor	:= If ( xValor , ".T.", ".F." )
EndIf

DbSelectArea('SX6')
DbSetOrder(1)

lRecLock := !MsSeek( Space( Len( X6_FIL ) ) + Padr( cMvPar, Len( X6_VAR ) ) )

If lRecLock
	
	RecLock( "SX6", lRecLock )
	
	FieldPut( FieldPos( "X6_VAR" ), cMvPar )
	
	FieldPut( FieldPos( "X6_TIPO" ), cTipo )
	
	FieldPut( FieldPos( "X6_PROPRI" ), "U" )
	
	If !Empty( cDescP )
		FieldPut( FieldPos( "X6_DESCRIC" ), SubStr( cDescP, 1, Len( X6_DESCRIC ) ) )
		FieldPut( FieldPos( "X6_DESC1" ), SubStr( cDescP, Len( X6_DESC1 ) + 1, Len( X6_DESC1 ) ) )
		FieldPut( FieldPos( "X6_DESC2" ), SubStr( cDescP, ( Len( X6_DESC2 ) * 2 ) + 1, Len( X6_DESC2 ) ) )
	EndIf
	
	If !Empty( cDescS )
		FieldPut( FieldPos( "X6_DSCSPA" ), cDescS )
		FieldPut( FieldPos( "X6_DSCSPA1" ), SubStr( cDescS, Len( X6_DSCSPA1 ) + 1, Len( X6_DSCSPA1 ) ) )
		FieldPut( FieldPos( "X6_DSCSPA2" ), SubStr( cDescS, ( Len( X6_DSCSPA2 ) * 2 ) + 1, Len( X6_DSCSPA2 ) ) )
	EndIf
	
	If !Empty( cDescE )
		FieldPut( FieldPos( "X6_DSCENG" ), cDescE )
		FieldPut( FieldPos( "X6_DSCENG1" ), SubStr( cDescE, Len( X6_DSCENG1 ) + 1, Len( X6_DSCENG1 ) ) )
		FieldPut( FieldPos( "X6_DSCENG2" ), SubStr( cDescE, ( Len( X6_DSCENG2 ) * 2 ) + 1, Len( X6_DSCENG2 ) ) )
	EndIf
	
	If lRecLock .Or. lAlter
		FieldPut( FieldPos( "X6_CONTEUD" ), xValor )
		FieldPut( FieldPos( "X6_CONTSPA" ), xValor )
		FieldPut( FieldPos( "X6_CONTENG" ), xValor )
	EndIf
	
	MsUnlock()
	
EndIf

xlReturn := GetNewPar(cMvPar)

RestArea( aAreaAtu )

Return(xlReturn)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SyTrataParºAutor  ³ SYMM Consultoria   º Data ³ 15/03/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua formatação das parametro, substituindo os traços (-),º±±
±±º          ³por vírgulas (,) para que o parametro seja utilizada querys.º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function SyTrataPar(cParQry)
Return StrTran(StrTran(cParQry,"'"),",","','")

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYRetFil  ºAutor  ³ SYMM Consultoria   º Data ³  12/14/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica os acessos do SX2							      º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function SyRetFil(cGrupo,cAlias1,cCampo1,cAlias2,cCampo2,cFilQry,lProcedure)

Local nPosAlias1 := 0
Local nPosAlias2 := 0
Local nPosGrp    := 0
Local cRet		 := ""
Local cDBMS 	 := AllTrim(Upper(TCGETDB()))

DEFAULT cAlias1 	:= ""
DEFAULT cAlias2 	:= ""
DEFAULT cFilQry 	:= ""
DEFAULT lProcedure	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as empresas que farao parte das consultas. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("aEmps") == "U" .OR. Len(aEmps) == 0
	aEmps := {}
	T_SyCarregaEmp(.T.)
EndIf

nPosGrp := AScan( aEmps, { |x| x[1] == cGrupo } )
If nPosGrp > 0
	nPosAlias1 := AScan( aEmps[nPosGrp,4], { |x| x[1] == cAlias1 } )
	nPosAlias2 := AScan( aEmps[nPosGrp,4], { |x| x[1] == cAlias2 } )
	
	//Verifica se eh para comparar as filiais entre tabelas diferentes
	If (nPosAlias2 > 0) .And. !Empty(cAlias2)
		
		//Compartilhado entre empresas, unidades e filiais
		If	(aEmps[nPosGrp,4,nPosAlias1,5] == "C") .And.;
			(aEmps[nPosGrp,4,nPosAlias2,5] == "C") .And.;
			(aEmps[nPosGrp,4,nPosAlias1,4] == "C") .And.;
			(aEmps[nPosGrp,4,nPosAlias2,4] == "C") .And.;
			(aEmps[nPosGrp,4,nPosAlias1,3] == "C") .And.;
			(aEmps[nPosGrp,4,nPosAlias2,3] == "C")
			
			If lProcedure
				cRet:= " AND " + cAlias1 + "." + cCampo1 + " = ''" + xFilial(cAlias1) + "''"
			Else
				cRet:= " AND " + cAlias1 + "." + cCampo1 + " = '" + xFilial(cAlias1) + "'"
			EndIf
			
			//Tudo exclusivo
		ElseIf	(aEmps[nPosGrp,4,nPosAlias1,5] == "E") .And.;
			(aEmps[nPosGrp,4,nPosAlias2,5] == "E") .And.;
			(aEmps[nPosGrp,4,nPosAlias1,4] == "E") .And.;
			(aEmps[nPosGrp,4,nPosAlias2,4] == "E") .And.;
			(aEmps[nPosGrp,4,nPosAlias1,3] == "E") .And.;
			(aEmps[nPosGrp,4,nPosAlias2,3] == "E")
			
			cRet:= " AND " + cAlias1 + "." + cCampo1 + " = " + cAlias2 + "." + cCampo2
			
			//Uma exclusiva e outra compartilhada
		ElseIf 	((aEmps[nPosGrp,4,nPosAlias1,5] == "E") .And. (aEmps[nPosGrp,4,nPosAlias2,5] == "C")) .Or.;
			((aEmps[nPosGrp,4,nPosAlias1,5] == "C") .And. (aEmps[nPosGrp,4,nPosAlias2,5] == "E"))
			
			If aEmps[nPosGrp,4,nPosAlias1,5] == "C"
				If lProcedure
					cRet:= " AND " + cAlias1 + "." + cCampo1 + " = ''" + xFilial(cAlias1) + "''"
				Else
					cRet:= " AND " + cAlias1 + "." + cCampo1 + " = '" + xFilial(cAlias1) + "'"
				EndIf
			EndIf
			
			//Empresa exclusiva e filiais excluvisa/compartilhada
		ElseIf 	(aEmps[nPosGrp,4,nPosAlias1,5] == "E") .And. (aEmps[nPosGrp,4,nPosAlias2,5] == "E") .And.;
			(	((aEmps[nPosGrp,4,nPosAlias2,3] == "E") .And. (aEmps[nPosGrp,4,nPosAlias1,3] == "C")) .Or.;
			((aEmps[nPosGrp,4,nPosAlias2,3] == "C") .And. (aEmps[nPosGrp,4,nPosAlias1,3] == "E"))		)
			
			If (aEmps[nPosGrp,5] == 0)
				cRet:= ""
			Else
				cRet:= " AND SUBSTRING(" + cAlias1 + "." + cCampo1 + ",1," + cValToChar(aEmps[nPosGrp,5]) + ") "
				cRet+= " = SUBSTRING(" + cAlias2 + "." + cCampo2 + ",1," + cValToChar(aEmps[nPosGrp,5]) + ") "
			EndIf
		EndIf
		//Retorna a Filial de Unica Tabela
	Else
		//Compartilhado entre empresas, unidades e filiais
		If	(aEmps[nPosGrp,4,nPosAlias1,5] == "C") .And.;
			(aEmps[nPosGrp,4,nPosAlias1,4] == "C") .And.;
			(aEmps[nPosGrp,4,nPosAlias1,3] == "C")
			
			cRet:= ""
			//Empresa excluvia e filiais excluvisa/compartilhada
		ElseIf 	(aEmps[nPosGrp,4,nPosAlias1,5] == "E") .And.;
			(aEmps[nPosGrp,4,nPosAlias1,4] == "E") .And.;
			(aEmps[nPosGrp,4,nPosAlias1,3] == "E")
			
			If (aEmps[nPosGrp,5] == 0)
				cRet:= ""
			Else
				cRet:= "AND " + cAlias1 + "." + cCampo1 + " = ''" + cFilQry + "''"
			EndIf
			//Empresa excluvia e filiais excluvisa/compartilhada
		ElseIf 	(aEmps[nPosGrp,4,nPosAlias1,5] == "E") .And.;
			(aEmps[nPosGrp,4,nPosAlias1,4] == "E") .And.;
			(aEmps[nPosGrp,4,nPosAlias1,3] == "C")
			
			If (aEmps[nPosGrp,5] == 0)
				cRet:= ""
			Else
				cRet:= "AND " + cAlias1 + "." + cCampo1 + " = " + cFilQry
			EndIf
		EndIf
	EndIf
Else
	cRet:= ""
EndIf

If cDBMS == "ORACLE"
	cRet := StrTran(cRet,"+","||")
	cRet := StrTran(cRet,"SUBSTRING","SUBSTR")
EndIf

Return cRet
