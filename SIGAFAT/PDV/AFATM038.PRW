#Include "Totvs.ch"
#INCLUDE "TbiConn.ch"

/*==========================================================================
Funcao...........:	AFATM038
Descricao........:	Importacao de Cadastros (Generica)
Autor............:	Eduardo Patriani
Data.............: 05/01/2016
Parametros.......:	Nil
Retorno..........:	Nil
==========================================================================*/
User Function AFATM038()

	Local oFontL	:= TFont():New('Arial',,12,,.T.,,,,,.F.,.F.)
	Local oDlg		:= Nil

	DEFINE MSDIALOG oDlg TITLE "Importação de Cadastros" FROM 000, 000  TO 300, 370 COLORS 0, 16777215 PIXEL

	//Montagem do Track
	cColorBackGround 	:= "#FFFFFF"
	cColorSeparator 	:= "#C0C0C0"
	cGradientTop 		:= "#57A2EE"
	cGradientBottom 	:= "#2BD0F7"	// Gradiente inicial do botao selecionado
	cColorText			:= "#000000"	// Gradiente final do botao selecionado
	oTrackMenu  		:= TTrackMenu():New( oDlg, 000, 000, 000, 000, {|o,cID| FuncTrack(o, cId ,oDlg) }, 40, cColorBackGround, cColorSeparator, cGradientTop, cGradientBottom, oFontL, cColorText )
	oTrackMenu:Align	:= CONTROL_ALIGN_ALLCLIENT

	oTrackMenu:Add("ID001", "Importação de Clientes"		, "SDUIMPORT.PNG"	)
	//oTrackMenu:Add("ID002", "Importação de Produtos Pai"	, "SDUIMPORT.PNG"	)
	oTrackMenu:Add("ID003", "Importação de Produtos"		, "SDUIMPORT.PNG"	)
	oTrackMenu:Add("ID004", "Importação de Fornecedores"	, "SDUIMPORT.PNG"	)
	oTrackMenu:Add("ID099", "Sair"							, "FINAL.PNG"		)

	ACTIVATE MSDIALOG oDlg CENTERED

Return Nil

/*==========================================================================
Funcao...........:	FuncTrack
Descricao........:	Rotinas do Track
Autor............:	Eduardo Patriani
Data.............: 05/01/2016
Parametros.......:	Nil
Retorno..........:	Nil
==========================================================================*/
Static Function FuncTrack( oTrackMenu, cId, oDlg )

	Local lRetorno	:= .T.

	//Clientes
	If cId == "ID001"
		ImpCsv( "SA1","A1" )

		/*Produtos Pai
	ElseIf cId == "ID002"
		ImpCsv( "SB4","B4" )
		*/

		//Produtos
	ElseIf cId == "ID003"
		ImpCsv( "SB1","B1" )

		//Fornecedores
	ElseIf cId == "ID004"
		ImpCsv( "SA2","A2" )

		//Sair
	ElseIf cId == "ID099"
		oDlg:End()

	EndIf

Return

/*==========================================================================
Funcao...........:	ImpCsv
Descricao........:	Importacao de Cadastro de cliente via CSV
Autor............:	Eduardo Patriani
Data.............: 05/01/2016
Parametros.......:	Nil
Retorno..........:	Nil
==========================================================================*/
Static Function ImpCsv( cTable, cPrefix )

	Local cArquivo	:= ""
	Local aHeader	:= {}
	Local aDados	:= {}
	Local aLogs		:= {}
	Local nQuant	:= 0
	Local lContinua	:= .T.

	FwMsgRun(,{|| lContinua := GetArq( cTable, @aHeader, @aDados, @nQuant ) }, , "Lendo Arquivo de origem, Por favor Aguarde" )

	If !lContinua
		Return Nil
	EndIf

	If !MsgYesNo( "Existe(m) " + Alltrim( Str( nQuant ) ) + " Registro(s), deseja fazer a importação" )
		Return Nil
	EndIf

	Processa({|| ProcArq( aHeader, aDados, nQuant, cPrefix, @aLogs, cTable ) },"Processando Importação, Por favor aguarde")

	If Len( aLogs ) > 0
		MostraLog( aLogs )
	EndIf

Return Nil

/*==========================================================================
Funcao...........:	GetArq
Descricao........:	Verifica a existencia do arquivo / Valida primeira 
Linha do arquivo.
Autor............:	Eduardo Patriani
Data.............: 05/01/2016
Retorno..........:	Variavel Logica
==========================================================================*/
Static Function GetArq( cTable, aHeader, aDados, nQuant )

	Local lRetorno	:= .T.
	Local nTamPre	:= Len( cTable )
	Local cFile		:= cGetFile( "Arquivo | *.csv"	,"Selecione o arquivo para transformação",,	,.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE )
	Local cBuffer	:= ""
	Local cAux		:= ""
	Local aAux		:= {}
	Local nX		:= 0

	If Empty( cFile )
		lRetorno := .F.
	Else

		FT_FUse( cFile )
		FT_FGoTop()

		cBuffer	:= FT_FREADLN()

		If SubStr( cBuffer,1,nTamPre ) <> cTable
			lRetorno := .F.
			Alert( "Arquivo .CSV inválido, verifique a primeira linha do arquivo" )
		Else

			//Pula uma linha
			FT_FSkip()

			cBuffer	:= FT_FREADLN()

			aHeader	:= StrToKArr( cBuffer, ";" )

			If Len( aHeader ) <= 0
				lRetorno := .F.
				Alert( "Formato inválido do arquivo, verifique" )
			Else

				//Pula uma linha
				FT_FSkip()

				While !FT_FEOF()

					cBuffer	:= FT_FREADLN()
					nQuant	:= nQuant + 1
					aAux	:= {}				
					//aAux	:= StrToKArr( cBuffer, ";" )	
					aAux	:= Separa( cBuffer, ";" )	

					Aadd( aDados, aAux )

					FT_FSkip()
				End

			EndIf

		EndIf

		FT_FUse()

	EndIf

Return lRetorno

/*==========================================================================
Funcao...........:	ProcArq
Descricao........:	Processa importacao (Via Execauto)
Autor............:	Eduardo Patriani
Data.............: 05/01/2016
==========================================================================*/
Static Function ProcArq( aHeader, aDados, nQuant, cPrefix, aLogs, cTable )

	Local cCampo	:= ""
	Local xValor	:= ""
	Local cMensagem	:= ""
	Local nInicio	:= If(cTable$"SA1|SA2",3,2)
	Local aValues	:= {}
	Local nX		:= 0
	Local nY		:= 0
	Local lAchou	:= .F.

	Local cCmpMac	:= ""
	Local cChvAux	:= ""
	Local cChave	:= ""
	Local cCodSYP	:= ""
	Local nTam		:= 0

	Local nAviso	:= Nil

	Private lMsErroAuto	:= .F.

	ProcRegua( nQuant )

	/*-----------------------------------------------------
	@Autor: Caio Pereira @Data: 19/08/2016 @Hora: 11:41:43
	@Descrição: Melhoria no processo para incluir clientes. 
	-------------------------------------------------------
	Change: XXXXX
	-----------------------------------------------------*/
	If cTable == "SA1"
		nAviso:= AVISO("Importação de Cliente", "Deseja efetuar qual procedimento?", {"Inclusão","Alteração"}, 1)
		If nAviso == 1
			ProcRegua(0)
			IncProc("Processando... aguarde.")

			//aLogs:= STARTJOB("U_AS038CLI()",GetEnvServer(),.T.,aHeader,aDados,cEmpAnt,cFilAnt,__cUserId)
			aLogs:= U_AS038CLI(aHeader,aDados,cEmpAnt,cFilAnt,__cUserId)

			Return()
		EndIf
	EndIf	

	//Processa Importacao
	For nX := 1 To Len( aDados )

		cMensagem := "Registro não encotrado"
		lAchou	  := .F.

		IncProc()

		If cTable=="SA1"

			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1") + AvKey(aDados[nX,1],"A1_COD") + AvKey(aDados[nX,2],"A1_LOJA") ))
				lAchou := .T.
				cMensagem := "Cliente: "+SA1->A1_NOME+" atualizado com sucesso."
			Endif

		Elseif cTable=="SA2"		

			SA2->(DbSetOrder(1))
			If SA2->(DbSeek(xFilial("SA2") + AvKey(aDados[nX,1],"A2_COD") + AvKey(aDados[nX,2],"A2_LOJA") ))
				lAchou := .T.
				cMensagem := "Cliente: "+SA2->A2_NOME+" atualizado com sucesso."
			Endif

		Elseif cTable=="SB1"

			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1") + AvKey(aDados[nX,1],"B1_COD") ))
				lAchou := .T.
				cMensagem := "Produto: "+SB1->B1_COD+" atualizado com sucesso."
			Endif

		Elseif cTable=="SB4"

			SB4->(DbSetOrder(1))
			If SB4->(DbSeek(xFilial("SB4") + AvKey(aDados[nX,1],"B4_COD") ))
				lAchou := .T.
				cMensagem := "Produto: "+SB4->B4_COD+" atualizado com sucesso."
			Endif

		Endif

		DbSelectarea("SX3")
		SX3->( DbSetorder(2) )

		For nY := nInicio To Len( aHeader )

			cCampo	:= Alltrim( aHeader[nY] )
			xValor	:= ""

			If SubStr( cCampo,1,2 ) == cPrefix

				If SX3->( DbSeek(cCampo) )
					If Alltrim( SX3->X3_TIPO ) == "C"
						xValor	:= Alltrim( aDados[nX][nY] )

					ElseIf Alltrim( SX3->X3_TIPO ) == "N"
						xValor	:= Val( aDados[nX][nY] )

					ElseIf Alltrim( SX3->X3_TIPO ) == "D"
						xValor	:= CtoD( aDados[nX][nY] )

					ElseIf Alltrim( SX3->X3_TIPO ) == "M"
						If SX3->X3_CONTEXT == "R"
							xValor	:= Alltrim(aDados[nX][nY])
						Else
							If !Empty(SX3->X3_RELACAO)

								nTam 	:= SX3->X3_TAMANHO
								cChvAux := StrTran(SX3->X3_RELACAO,")",",")
								cChave 	:= SubStr(cChvAux,at('->',cChvAux)+2,10)		
								cChave 	:= IIf(at(",",cChave)==0,Alltrim(cChave),Alltrim(SubStr(cChave,1,at(",",cChave)-1)))		
								cCmpMac := cTable+"->"+cChave

								cCodSYP := &cCmpMac

								xValor := U_NewMsMM(cCodSYP,cTable,cChave,aDados[nX][nY],nTam)
								cCampo := cChave
							EndIf
						EndIf
					EndIf

				EndIf

			EndIf

			//Grava a informacao na tabela
			If lAchou
				RecLock(cTable,.F.)
				Replace &(cCampo) With xValor 
				Msunlock()
			Endif

		Next nY

		//Registra LOG do processamento
		Aadd( aLogs,{	lAchou				,;
		StrZero( nX+2, 6)	,;
		cMensagem 			})

	Next nX

Return Nil

/*==========================================================================
Funcao...........:	MostraLog
Descricao........:	Tela para exibir LOG
Autor............:	Eduardo Patriani
Data.............: 05/01/2016
==========================================================================*/
Static Function MostraLog( aLogs )
	Local oFontL 	:= TFont():New("Mono AS",,012,,.T.,,,,,.F.,.F.)
	Local cMask    	:= "Arquivos Texto" + "(*.TXT)|*.txt|"
	Local cMemo		:= ""
	Local cFile    	:= ""
	Local cTexto   	:= ""
	Local oBtnSair
	Local oGrpLog
	Local oPanelB
	Local oMemo
	Local oDlgLog

	DEFINE MSDIALOG oDlgLog TITLE "Log de Processamento" FROM 000, 000  TO 400, 700 COLORS 0, 16777215 PIXEL

	@ 182, 000 MSPANEL oPanelB SIZE 350, 017 OF oDlgLog COLORS 0, 16777215 RAISED
	oPanelB:Align	:= CONTROL_ALIGN_BOTTOM

	@ 002, 002 LISTBOX oLogs Fields HEADER "","Linha do Arquivo" SIZE 100, 176 OF oDlgLog PIXEL ColSizes 50,50
	oLogs:SetArray(aLogs)
	oLogs:bChange	:= {|| 	cMemo := aLogs[oLogs:nAt,3], oMemo:Refresh() }
	oLogs:bLine		:= {||	{;
	IF( aLogs[oLogs:nAt,1], LoadBitmap( GetResources(), "BR_VERDE" ), LoadBitmap( GetResources(), "BR_VERMELHO" ) ),;
	aLogs[oLogs:nAt,2];
	}}

	@ 001, 105 GROUP oGrpLog TO 178, 350 PROMPT " Log do Processamento " OF oDlgLog COLOR 0, 16777215 PIXEL

	@ 009, 107 GET oMemo VAR cMemo OF oDlgLog MULTILINE SIZE 240, 166 COLORS 0, 16777215 HSCROLL PIXEL Font oFontL

	DEFINE SBUTTON oBtnSair	FROM 185, 150 TYPE 01 OF oDlgLog ENABLE Action( oDlgLog:End() )
	DEFINE SBUTTON oBtnSave	FROM 185, 180 TYPE 13 OF oDlgLog ENABLE Action( cFile := cGetFile( cMask, "" ), If( Empty(cFile), .T., GrvLog( aLogs, cFile ) ) )

	ACTIVATE MSDIALOG oDlgLog CENTERED

Return Nil

/*==========================================================================
Funcao...........:	GrvLog
Descricao........:	Gravacao do LOG em arquivo
Autor............:	Eduardo Patriani
Data.............: 05/01/2016
==========================================================================*/
Static Function GrvLog( aLogs, cFile )
	Local nHandle	:= MsfCreate( cFile,0 )
	Local cTexto	:= ""
	Local nX		:= 0

	If nHandle <= 0
		MsgInfo("Não foi possível criar o arquivo, verifique")
		Return Nil
	Endif

	//Gera o Arquivo Tabulado
	For nX := 1 To Len( aLogs )

		//Armazena Loc
		cTexto := "Linha: " + aLogs[nX][02] + Space( 5 ) + aLogs[nX][03]

		//Grava Linha
		FWrite( nHandle, cTexto + CRLF )

	Next nX

	FClose(nHandle)

	MsgInfo( "Arquivo " + Alltrim( cFile ) + " gravado com sucesso" )

Return Nil

/*--------------------------------------------
@Autor: Caio Pereira
@Data: 19/08/2016
@Hora: 11:44:25
@Versão: 
@Uso: Asics Brasil
@Descrição: Funcao que efetua o cadastro do
cliente.
---------------------------------------------
Change: XXXXX
--------------------------------------------*/
User Function AS038CLI(aHeader,aDados,cEmp,cFil,cUserRot)

	Local aClientes := {}
	Local aColsSA1	:= {}
	Local aLogs	:= {}

	Local nX		:= 0
	Local nY		:= 0  

	Local cErro	:= "\DEBUG\ASCRIACLI\"	
	Local cArqLog	:= "" 
	Local cMensagem	:= ""

	Local xValor	:= Nil

	Local aAuxMemo	:= {}
	Local nPosCli 	:= 0
	Local nPosLj	:= 0
	Local nInd		:= 0
	Local cChvAux	:= ""
	Local cChave	:= ""
	Local cCliente	:= ""
	Local cCliLoja	:= ""
	Local cCodSYP	:= ""

	Default aHeader	:= {}
	Default aDados	:= {} 
	Default cEmp	:= ""
	Default cFil	:= ""
	Default cUserRot:= ""

	MakeDir(cErro)

	//RPCSetType(3)
	//PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil

	Begin Transaction

		__cUserId := cUserRot
		cUsuario  := cUserRot

		For nX:= 1 To Len(aDados)

			aClientes:= {}

			For nY:= 1 To Len(aHeader)		

				SX3->(DbSetOrder(2))
				If SX3->(DbSeek(Padr(aHeader[nY],10)))	
					If Alltrim( SX3->X3_TIPO ) == "C"
						xValor	:= Alltrim(aDados[nX][nY])
					ElseIf Alltrim( SX3->X3_TIPO ) == "N"
						xValor	:= Val(aDados[nX][nY])
					ElseIf Alltrim( SX3->X3_TIPO ) == "D"
						xValor	:= CtoD(aDados[nX][nY])
					ElseIf Alltrim( SX3->X3_TIPO ) == "M"
						If SX3->X3_CONTEXT == "R"
							xValor	:= Alltrim(aDados[nX][nY])
						Else
							If !Empty(SX3->X3_RELACAO)
								aAdd(aAuxMemo,{SX3->X3_CAMPO,Alltrim(aDados[nX][nY]),SX3->X3_RELACAO,SX3->X3_TAMANHO})
								Loop
							EndIf
						EndIf

					EndIf

					aAdd(aClientes,{aHeader[nY],xValor,"AllwaysTrue()",Posicione("SX3",2,aHeader[nY],"X3_ORDEM")})
				EndIf	

			Next nY

			If Len(aAuxMemo) > 0

				For nInd:=1 to Len(aAuxMemo)
					nTam	:= aAuxMemo[nInd][4]
					cChvAux := StrTran(aAuxMemo[nInd][3],")",",")
					cChave 	:= SubStr(cChvAux,at('->',cChvAux)+2,10)
					cChave 	:= IIf(at(",",cChave)==0,AllTrim(cChave),AllTrim(SubStr(cChave,1,at(",",cChave)-1)) )

					nPosCli := Ascan(aClientes,{|a| AllTrim(a[1][1])=="A1_COD"})
					nPosLj	:= Ascan(aClientes,{|a| AllTrim(a[1][1])=="A1_LOJA"})

					If nPosCli > 0 .And.  nPosLj > 0
						cCliente := aClientes[nPosCli][2]  
						cCliLoja := aClientes[nPosLj][2]  					

						cCodSYP := Posicione("SA1",1,xFilial("SA1")+cCliente+cCliLoja,cChave)
						cCodSYP := U_NewMsMM(cCodSYP,"SA1",cChave,aAuxMemo[nInd][2],nTam)

						If !Empty(cCodSYP)
							aAdd(aClientes,{cChave,cCodSYP,"AllwaysTrue()",Posicione("SX3",2,cChave,"X3_ORDEM")})
						EndIf
					EndIf

				Next nInd
			EndIf

			If Len(aClientes) > 0
				aColsSA1:= {}			
				For nY:=1 To Len(aClientes)
					If aClientes[nY][2] <> Nil
						AADD(aColsSA1,AClone(aClientes[nY]))
					EndIf
				Next nY

				ASort( aColsSA1, Nil, Nil, {|x,y| x[4] < y[4] } )

				lMsErroAuto:= .F.

				MSExecAuto( {|x,y| MATA030(x,y)},aColsSA1,3)

				If lMsErroAuto
					cArqLog:= "ERRO_CLIENTE.txt"
					cMensagem:= MostraErro(cErro,cArqLog) 
					Aadd( aLogs,{.F.,StrZero(nX, 6),cMensagem})						
				Else
					cMensagem:= "Cliente da linha "+StrZero(nX, 6)+" incluído com sucesso."+CRLF
					cMensagem+= "Cliente "+SA1->A1_COD+" Loja "+SA1->A1_LOJA+CRLF
					cMensagem+= "Nome "+SA1->A1_NREDUZ				
					Aadd( aLogs,{.T.,StrZero(nX, 6),cMensagem})	
				EndIf

			EndIf

		Next nX

		For nX:= 1 To Len(aLogs)
			If !aLogs[nX][1]
				DisarmTransaction()
				//RESET ENVIRONMENT
				Return(aLogs)
			EndIf
		Next nX		

	End Transaction

	//RESET ENVIRONMENT			

Return(aLogs)


/*/{Protheus.doc} NewMsMM
//TODO Descrição rotina que apaga e cria um novo registro no campo Memo - Virtual.

@author Lucas
@since 02/01/2018
@version 1.0
@return ${return}, ${return_description}

@param cCodSYP, characters, código de SYP criado anteriormente
@param cTab, characters, Tabela que será gravada
@param cCampo, characters, campo que receberá o código de SYP
@param cDados, characters, texto que será incluso no campo memo

@type function
/*/
User Function NewMsMM(cCodSYP,cTab,cCampo,cDados,nTam)

	Local aAreaAtu 	:= GetArea()
	Local xRet

	Default cCodSYP := ""
	Default nTam := 30

	If !Empty(cCampo) .And. !Empty(cCodSYP)

		MSMM(cCodSYP,,,,2)

		xRet := MSMM(,nTam,,cDados,1,,,cTab,cCampo,"SYP")

		If ValType(xRet) == "C"
			cCodSYP := xRet
		EndIf
	ElseIf !Empty(cCampo)
		xRet := MSMM(,nTam,,cDados,1,,,cTab,cCampo,"SYP")

		If ValType(xRet) == "C"
			cCodSYP := xRet
		EndIf
	EndIf

	RestArea(aAreaAtu)

Return cCodSYP