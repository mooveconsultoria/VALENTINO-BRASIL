#INCLUDE "PROTHEUS.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'RWMAKE.CH'

/*/{Protheus.doc} SYCADCLI
Efetua o cadastro do cliente no novo PDV.
@author Douglas Telles
@since 07/03/2016
@version 1.0
/*/
User function SYCADCLI()
	Local aSize 	   := MsAdvSize()
	Local cRet  	   := CriaVar("A1_CGC",.F.)
	Local oDlg

	Private aPessoa  := {'F=Fisica','J=Juridica'}
	Private cPessoa  := 'F=Fisica'
	Private aIndEst  := {'N=Não','S=Sim'}
	Private cIndEst  := 'N=Não'

	Private lEditCli := .T.

	DEFINE MSDIALOG oDlg TITLE "Cadastro de Cliente" FROM 180, 012  TO aSize[6]+(aSize[6]*(5/100)), aSize[5]-(aSize[5]*(51/100));
		COLORS 0, 16777215 PIXEL STYLE WS_VISIBLE

	oTSay0:= TSay():Create(oDlg,{||'Preencha os campos abaixo para INCLUIR ou ALTERAR o Cadastro do Cliente:'},01,09,,,,,,.T.,CLR_RED,,200,20)

//==========================================================================================================
//Descricao e campo para codigo do cliente
//==========================================================================================================
/*oTSayCod:= TSay():Create(oDlg,{||'Código*:'},15,09,,,,,,.T.,CLR_RED,,200,20)
cTGetCod := space(TamSx3("A1_COD")[1])
@ 15,45 MSGET oTGetCod VAR cTGetCod VALID VLDCODCLI(.T.) SIZE 50,9 PICTURE "@!" When lEditCli OF oDlg PIXEL*/

//==========================================================================================================
//Descricao e campo para codigo do ID Retail
//==========================================================================================================
	oTSayCod:= TSay():Create(oDlg,{||'ID Retail:'},15,09,,,,,,.T.,CLR_RED,,200,20)
	cTGetCod := space(TamSx3("A1_XIDRETA")[1])
	@ 15,45 MSGET oTGetCod VAR cTGetCod VALID VLDCODCLI(.T.) SIZE 50,9 PICTURE "@!" When .T. OF oDlg PIXEL

/**==========================================================================================================**
** Descricao e campo para CPF
**==========================================================================================================**/
	oTSay1:= TSay():Create(oDlg,{||'CPF*:'},15,110,,,,,,.T.,CLR_RED,,200,20)
	cTGet1 := space(TamSx3("A1_CGC")[1])
	@ 15,130 MSGET oTGet1 VAR cTGet1 VALID VLDCPF(.T.) SIZE 50,9 PICTURE "@R 999.999.999-99" When .t. OF oDlg PIXEL

/**==========================================================================================================**
** Descricao e campo para RG
**==========================================================================================================**/
	oTSay16:= TSay():Create(oDlg,{||'RG/Passaporte:'},15,200,,,,,,.T.,,,200,20)
	cTGet16 := space(9)
	@ 15,245 MSGET oTGet16 VAR cTGet16 VALID VLDRG(.T.) SIZE 50,9 PICTURE "@!" When .t. OF oDlg PIXEL

/**==========================================================================================================**
** Descricao e campo para Nome
**==========================================================================================================**/
	oTSay2:= TSay():Create(oDlg,{||'Nome*:'},35,09,,,,,,.T.,CLR_RED,,200,20)
	cTGet2 := space(TamSx3("A1_NOME")[1])
	@ 35,45 MSGET oTGet2 VAR cTGet2 SIZE 165,9 PICTURE "@!" When .t. OF oDlg PIXEL

/**==========================================================================================================**
** Descricao e campo para CEP
**==========================================================================================================**/
	oTSay3:= TSay():Create(oDlg,{||'CEP*:'},35,225,,,,,,.T.,CLR_RED,,200,20)
	cTGet3 := space(TamSx3("A1_CEP")[1])
	@ 35,245 MSGET oTGet3 VAR cTGet3 SIZE 70,9 VALID U_fBuscaCep(cTGet3) /*VERCEP(cTGet3)*/ PICTURE "@R 99999-999" When .t. OF oDlg PIXEL

/**==========================================================================================================**
** Descricao e campo para Endereco
**==========================================================================================================**/
	oTSay4:= TSay():Create(oDlg,{||'Endereço*:'},55,09,,,,,,.T.,CLR_RED,,200,20)
	cTGet4 := space(TamSx3("A1_END")[1])
	@ 55,45 MSGET oTGet4 VAR cTGet4 SIZE 265,9 PICTURE "@!" When .t. OF oDlg PIXEL

/**==========================================================================================================**
** Descricao e campo para Complemento do Endereco
**==========================================================================================================**/
	oTSay6:= TSay():Create(oDlg,{||'Complem.:'},75,09,,,,,,.T.,,,200,20)
	cTGet6 := space(TamSx3("A1_COMPLEM")[1])
	@ 75,45 MSGET oTGet6 VAR cTGet6 SIZE 170,9 PICTURE "@!" When .t. OF oDlg PIXEL

/**==========================================================================================================**
** Descricao e campo para Bairro
**==========================================================================================================**/
	oTSay7:= TSay():Create(oDlg,{||'Bairro*:'},95,09,,,,,,.T.,CLR_RED,,200,20)
	cTGet7 := space(TamSx3("A1_BAIRRO")[1])
	@ 95,45 MSGET oTGet7 VAR cTGet7 SIZE 95,9 PICTURE "@!" When .t. OF oDlg PIXEL

/**==========================================================================================================**
** Descricao e campo para Municipio
**==========================================================================================================**/
	oTSay8:= TSay():Create(oDlg,{||'Municipio*:'},95,157,,,,,,.T.,CLR_RED,,200,20)
	cTGet8 := space(TamSx3("A1_MUN")[1])
	@ 95,190 MSGET oTGet8 VAR cTGet8 SIZE 120,9 PICTURE "@!" When .t. OF oDlg PIXEL

/**==========================================================================================================**
** Descricao e campo para Estado
**==========================================================================================================**/
	oTSay9:= TSay():Create(oDlg,{||'Estado*:'},115,09,,,,,,.T.,CLR_RED,,200,20)
	cTGet9 := space(TamSx3("A1_EST")[1])
	@ 115,45 MSGET oTGet9 VAR cTGet9 SIZE 40,9 PICTURE "@!" When .t. OF oDlg PIXEL

/**==========================================================================================================**
** Descricao e campo para Tipo de Pessoa
**==========================================================================================================**/
	oTSay10:= TSay():Create(oDlg,{||'Pessoa:'},115,147,,,,,,.T.,,,200,20)
	cTGet10 := space(TamSx3("A1_PESSOA")[1])
	@ 115,183 COMBOBOX oTGet10 VAR cPessoa ITEMS aPessoa When .T. OF oDlg PIXEL SIZE 40,9

/**==========================================================================================================**
** Descricao e campo para Identificar Estrangeiro
**==========================================================================================================**/
	oTSay17:= TSay():Create(oDlg,{||'Estrangeiro:'},115,230,,,,,,.T.,,,200,20)
	cTGet17 := cIndEst
	@ 115,263 COMBOBOX oTGet17 VAR cIndEst ITEMS aIndEst VALID AtuObrig(oDlg) When .T. OF oDlg PIXEL SIZE 40,9

/**==========================================================================================================**
** Descricao e campo para Telefone
**==========================================================================================================**/
	oTSay11:= TSay():Create(oDlg,{||'Telefone:'},135,09,,,,,,.T.,,,200,20)
	cTGet11 := space(TamSx3("A1_TEL")[1])
	@ 135,45 MSGET oTGet11 VAR cTGet11 SIZE 80,9 PICTURE "@R (99)99999-9999" When .t. OF oDlg PIXEL

/**==========================================================================================================**
** Descricao e campo para E-mail
**==========================================================================================================**/
	oTSay13:= TSay():Create(oDlg,{||'Email:'},155,09,,,,,,.T.,,,200,20)
	cTGet13 := space(TamSx3("A1_EMAIL")[1])
	@ 155,45 MSGET oTGet13 VAR cTGet13 SIZE 265,9 PICTURE "@!" When .t. OF oDlg PIXEL

/**==========================================================================================================**
** Descricao e campo para Data de Nascimento
**==========================================================================================================**/
	oTSay14:= TSay():Create(oDlg,{||'Dt. Nasc.:'},175,09,,,,,,.T.,,,200,20)
	cTGet14 := CriaVar("A1_DTNASC",.F.)
	@ 175,45 MSGET oTGet14 VAR cTGet14 SIZE 80,9 When .t. OF oDlg PIXEL

/**==========================================================================================================**
** Descricao e campo para Data de Cadastro
**==========================================================================================================**/
	oTSay15:= TSay():Create(oDlg,{||'Dt. Cadastro:'},175,147,,,,,,.T.,,,200,20)
	cTGet15 := dDataBase
	@ 175,183 MSGET oTGet15 VAR cTGet15 SIZE 80,9 When .F. OF oDlg PIXEL

/**==========================================================================================================**
** Descricao e campo para Pais
**==========================================================================================================**/
	oTSay20:= TSay():Create(oDlg,{||'País Bacen'},195,09,,,,,,.T.,,,200,20)
	cTGet20 := CriaVar("A1_PAIS",.F.)
	@ 195,45 MSGET oTGet20 VAR cTGet20 SIZE 80,9 F3 'SYA' When IIF(oTGet17:nAt==2,.T.,.F.) OF oDlg PIXEL

	oTSay19:= TSay():Create(oDlg,{||'Cod Pais:'},195,147,,,,,,.T.,,,200,20)
	cTGet19 := CriaVar("A1_CODPAIS",.F.)
	@ 195,183 MSGET oTGet19 VAR cTGet19 SIZE 80,9 F3 'CCH' When IIF(oTGet17:nAt==2,.T.,.F.) OF oDlg PIXEL

/**==========================================================================================================**
** Botoes do cadastro de cliente
**==========================================================================================================**/
	oTButton1 := TButton():Create( oDlg,210,060,"Confirmar",{||Confirma(oDlg)	},LARGBTN,ALTURABTN,,,,.T.,,,,,,)
	oTButton2 := TButton():Create( oDlg,210,160,"Cancelar" ,{||oDlg:End()		},LARGBTN,ALTURABTN,,,,.T.,,,,,,)

/**==========================================================================================================**
** Define estilo da descricao dos campos
**==========================================================================================================**/
	oTSayCod:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
	oTSay1:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
	oTSay2:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
	oTSay3:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
	oTSay4:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
	oTSay6:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
	oTSay7:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
	oTSay8:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
	oTSay9:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
	oTSay10:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
	oTSay11:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
	oTSay13:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
	oTSay14:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
	oTSay15:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
	oTSay19:SetCSS( POSCSS(CSS_LABEL_FOCAL) )
	oTSay20:SetCSS( POSCSS(CSS_LABEL_FOCAL) )

/**==========================================================================================================**
** Define estilo dos campos
**==========================================================================================================**/
	oTGetCod:SetCSS( POSCSS(CSS_GET_NORMAL) )
	oTGet1:SetCSS( POSCSS(CSS_GET_NORMAL) )
	oTGet2:SetCSS( POSCSS(CSS_GET_NORMAL) )
	oTGet3:SetCSS( POSCSS(CSS_GET_NORMAL) )
	oTGet4:SetCSS( POSCSS(CSS_GET_NORMAL) )
	oTGet6:SetCSS( POSCSS(CSS_GET_NORMAL) )
	oTGet7:SetCSS( POSCSS(CSS_GET_NORMAL) )
	oTGet8:SetCSS( POSCSS(CSS_GET_NORMAL) )
	oTGet9:SetCSS( POSCSS(CSS_GET_NORMAL) )
	oTGet10:SetCSS( POSCSS(CSS_GET_NORMAL) )
	oTGet11:SetCSS( POSCSS(CSS_GET_NORMAL) )
	oTGet13:SetCSS( POSCSS(CSS_GET_NORMAL) )
	oTGet14:SetCSS( POSCSS(CSS_GET_NORMAL) )
	oTGet15:SetCSS( POSCSS(CSS_GET_NORMAL) )
	oTGet19:SetCSS( POSCSS(CSS_GET_NORMAL) )
	oTGet20:SetCSS( POSCSS(CSS_GET_NORMAL) )

/**==========================================================================================================**
** Define estilo dos botoes
**==========================================================================================================**/
	oTButton1:SetCSS( POSCSS(CSS_BTN_FOCAL) )
	oTButton2:SetCSS( POSCSS(CSS_BTN_ATIVO) )

	ACTIVATE MSDIALOG oDlg

Return

/*/{Protheus.doc} Confirma
Ações a serem executadas ao ser acionado o botão confirma.
@author Douglas Telles
@since 08/03/2016
@version 1.0
@param oDlg, objeto, Objeto contendo as informações do cliente.
/*/
Static function Confirma(oDlg)

	Local aDados		:= {}
	Local idRetail		:= cTGetCod
	Local cCodCli		:= IIF(oTGet17:nAt==1,STICodeGenerator(cTGet1),'')	//Geração do codigo do cliente
	Local lOk			:= .T.
	Local cMsg			:= ""
	Local cCodMun		:= ""
	Local cConOut		:= ""
	Local aResRet		:= {.F.,'',{}}

	If oTGet17:nAt==2 .and. Empty(cTGet16)
		MsgInfo("Cliente Estrangeiro, precisa ter Campo RG\Passaporte preenchido","Atenção")
		Return
	Endif

	lOk := TUDOOK()

	If lOk
		STFMessage(ProcName(),"STOP","Cadastrando Cliente na Retaguarda. Aguarde...")
		STFShowMessage(ProcName())
	
		CursorWait()
		oDlg:End()
	
		cCodMun := POSICIONE( "CC2", 4,xFilial("CC2")+Upper(AllTrim(cTGet9))+Upper(FwNoAccent(AllTrim(cTGet8))), "CC2_CODMUN" )
	
		aAdd(aDados, xFilial('SA1')	) 	// 01 - A1_FILIAL	=>	Filial
		aAdd(aDados, cCodCli			) 	// 02 - A1_COD		=>	Codigo
		aAdd(aDados, "01"				) 	// 03 - A1_LOJA		=>	Loja
		aAdd(aDados, DTOC(dDataBase)	) 	// 04 - A1_DTINIV	=>	Dia do cadastro
		aAdd(aDados, cTGet1			) 	// 05 - A1_CGC		=>	CGC (CPF / CNPJ)
		aAdd(aDados, cTGet2			) 	// 06 - A1_NOME		=>	Nome
		aAdd(aDados, cTGet2			) 	// 07 - A1_NREDUZ	=>	Nome Reduzido
		aAdd(aDados, cTGet3			) 	// 08 - A1_CEP		=>	CEP
		aAdd(aDados, cTGet4			) 	// 09 - A1_END		=>	Endereco
		aAdd(aDados, cTGet6			) 	// 10 - A1_COMPLEM	=>	Complemento
		aAdd(aDados, cTGet7			) 	// 11 - A1_BAIRRO	=>	Bairro
		aAdd(aDados, cTGet11			) 	// 12 - A1_TEL		=>	Telefone
		aAdd(aDados, "" 				) 	// 13 - A1_XCELCLI	=>	Celular
		aAdd(aDados, cTGet13			) 	// 14 - A1_EMAIL	=>	Email
		aAdd(aDados, DTOC(cTGet14)	) 	// 15 - A1_DTNASC	=>	Data de Nascimento
		aAdd(aDados, cTGet9			)	// 16 - A1_EST		=>	Estado
		aAdd(aDados, cTGet8			) 	// 17 - A1_MUN		=>	Municipio
		aAdd(aDados, cCodMun			) 	// 18 - A1_COD_MUN	=>	Codigo do Municipio
		aAdd(aDados, cPessoa			) 	// 19 - A1_PESSOA	=>	Pessoa (Fisica / Juridica)
		aAdd(aDados, "ISENTO"			) 	// 20 - A1_INSCR	=>	Inscricao
		aAdd(aDados, "F"				) 	// 21 - A1_TIPO		=>	Tipo de Cliente
		aAdd(aDados, IIF(oTGet17:nAt==1,"105",cTGet20)			) // 22 - A1_PAIS		=>	Codigo do Pais
		aAdd(aDados, "VDD"			) 	// 23 - A1_GRPTRIB	=>	Grupo Tributario
		aAdd(aDados, IIF(oTGet17:nAt==1,"01058",cTGet19)) // 24 - A1_CODPAIS	=>	Cod do Pais (Segundo a tabela do banco central do Brasil)
		aAdd(aDados, '2'				) // 25 - A1_MSBLQL	=>	Bloqueado (1=Sim, 2=Nao)
		aAdd(aDados, "1"				) // 26 - A1_TIPCLI	=>	Tipo de Cliente
		aAdd(aDados, "1"				) // 27 - A1_TIPOCLI	=>	Tipo de Cliente
		aAdd(aDados, "OK"				) // 28 - A1_SITUA	=>	Situacao do Cadastro do cliente
		aAdd(aDados, ""				) // 29 - A1_XNUMEND	=>	Numero do endereco
		aAdd(aDados, cTGet16			) // 30 - A1_PFISICA	=>	RG/Passaporte
		aAdd(aDados, oTGet17:nAt==2	) // 31 - 1=Estrangeiro-Nao, 2=Estrangeiro-Sim
		aAdd(aDados, idRetail			) // 32 - A1_XIDRETA	=>	ID Retail
		
		aResRet	:= SYCONRET(aDados) // Efetua a inclusao/alteracao do cliente na Retaguarda
		lOk 	:= aResRet[1]
	
		If lOk
			STFMessage(ProcName(),"STOP","Cadastrando Cliente no Ambiente Local. Aguarde...")
			STFShowMessage(ProcName())
		
			cConOut := "Dados Enviados Para Retaguarda" + CRLF
			cConOut += "Codigo        -> " + aDados[2]  + CRLF
			cConOut += "Loja          -> " + aDados[3]  + CRLF
			cConOut += "CPF           -> " + aDados[5]  + CRLF
			cConOut += "RG/Passaporte -> " + aDados[30] + CRLF
			Conout(cConOut)
		
			//Valida se o codigo do cliente esta vazio
			aDados := aResRet[3][2]
		
			cConOut := "Dados Utilizados Na Retaguarda" + CRLF
			cConOut += "Codigo        -> " + aDados[2]  + CRLF
			cConOut += "Loja          -> " + aDados[3]  + CRLF
			cConOut += "CPF           -> " + aDados[5]  + CRLF
			cConOut += "RG/Passaporte -> " + aDados[30] + CRLF
			Conout(cConOut)
		
			DbSelectArea("SA1")
			If !(aResRet[3][1]) // Alteracao na Retaguarda
				DbSetOrder(1) // FILIAL + COD + LOJA
				If DbSeek(xFilial("SA1")+aDados[2]+aDados[3])
					cMsg 		:= "Cliente alterado com sucesso!"
					cCodCli 	:= SA1->A1_COD
					Reclock("SA1",.F.)
				Else
					cCodCli 	:= aDados[2]
					cMsg 		:= "Cliente incluido com sucesso!"
					Reclock("SA1",.T.)
					SA1->A1_FILIAL 		:= xFilial('SA1')
					SA1->A1_COD    		:= aDados[2]
					SA1->A1_LOJA   		:= '01'
					SA1->A1_DTINIV  		:= dDataBase
				EndIf
		
			Else // Inclusao na Retaguarda
				cCodCli 	:= aDados[2]
				cMsg 		:= "Cliente incluido com sucesso!"
				Reclock("SA1",.T.)
				SA1->A1_FILIAL 		:= xFilial('SA1')
				SA1->A1_COD    		:= aDados[2]
				SA1->A1_LOJA   		:= '01'
				SA1->A1_DTINIV  		:= dDataBase
			EndIf
		
			SA1->A1_CGC    	:= aDados[5]
			SA1->A1_NOME   	:= aDados[6]
			SA1->A1_NREDUZ 	:= aDados[7]
			SA1->A1_CEP    	:= aDados[8]
			SA1->A1_END    	:= aDados[9]
			SA1->A1_COMPLEM	:= aDados[10]
			SA1->A1_BAIRRO 	:= aDados[11]
			SA1->A1_TEL    	:= aDados[12]
			SA1->A1_EMAIL  	:= aDados[14]
			SA1->A1_DTNASC 	:= CTOD(aDados[15])
			SA1->A1_EST    	:= aDados[16]
			SA1->A1_MUN    	:= aDados[17]
			SA1->A1_COD_MUN	:= aDados[18]
			SA1->A1_PESSOA		:= aDados[19]
			SA1->A1_INSCR		:= aDados[20]
			SA1->A1_TIPO   	:= aDados[21]
			SA1->A1_PAIS   	:= aDados[22]
			SA1->A1_GRPTRIB	:= "CLI"//aDados[23]
			SA1->A1_CODPAIS	:= aDados[24]
			SA1->A1_MSBLQL		:= aDados[25]
			SA1->A1_TIPCLI 	:= aDados[26]
			SA1->A1_TIPOCLI 	:= aDados[27]
			SA1->A1_SITUA  	:= aDados[28]
			SA1->A1_PFISICA	:= aDados[30]
			SA1->A1_XIDRETA	:= aDados[32]
		
			If AllTrim(SA1->A1_PESSOA) == "F"
				SA1->A1_CONTRIB	:= "2"
			EndIf
			MsUnlock()
		
			Conout("Finalizou a Inclusao/Alteracao do Cliente no PDV.")
		
			STFMessage(ProcName(),"STOP",cMsg /*+ " Cliente Selecionado."*/)
		
			CursorArrow()
			STIRegItemInterface()
			STFShowMessage(ProcName())
		Else
			CursorArrow()
			STFMessage(ProcName(),"STOP",aResRet[2] + "Informe o Administrador.")
			STFShowMessage(ProcName())
		EndIf
	EndIf
Return .T.

/*/{Protheus.doc} VLDCODCLI
Verifica se o codigo de cliente informado já existe na base de dados.
@author Eduardo Patiani
@since 08/03/2016
@version 1.0
@param lCampo, logico, Verifica se a validação está sendo efetuada pelo campo para atualizar informações.
/*/
Static Function VLDCODCLI(lCampo)

	Local aArea 	:= getarea()

	DEFAULT lCampo	:= .F.

	If oTGet17:nAt == 1 // Estrangeiro - Nao
	
		dbselectarea("SA1")
		dbsetorder(13)
		If lCampo .And. dbseek(xFilial("SA1")+cTGetCod)
			cTGet1	 := SA1->A1_CGC
			cTGet2	 := SA1->A1_NOME
			cTGet3	 := SA1->A1_CEP
			cTGet4	 := SA1->A1_END
			cTGet6	 := SA1->A1_COMPLEM
			cTGet7	 := SA1->A1_BAIRRO
			cTGet8  := SA1->A1_MUN
			cTGet9	 := SA1->A1_EST
			cPessoa := SA1->A1_PESSOA
			cTGet11 := SA1->A1_TEL
			cTGet13 := SA1->A1_EMAIL
			cTGet14 := SA1->A1_DTNASC
			cTGet15 := SA1->A1_DTINIV
			cTGet16 := SA1->A1_PFISICA
			cTGet19 := SA1->A1_CODPAIS
			cTGet20 := SA1->A1_PAIS
		
	/*
	ElseIf lCampo .And. !(dbseek(xFilial("SA1")+cTGetCod))
		cTGet1	 := space(TamSx3("A1_CGC")[1])
		cTGet2	 := space(TamSx3("A1_NOME")[1])
		cTGet3	 := space(TamSx3("A1_CEP")[1])
		cTGet4	 := space(TamSx3("A1_END")[1])
		cTGet6	 := space(TamSx3("A1_COMPLEM")[1])
		cTGet7	 := space(TamSx3("A1_BAIRRO")[1])
		cTGet8  := space(TamSx3("A1_MUN")[1])
		cTGet9	 := space(TamSx3("A1_EST")[1])
		cPessoa := 'F=Fisica'
		cTGet11 := space(TamSx3("A1_TEL")[1])
		cTGet13 := space(TamSx3("A1_EMAIL")[1])
		cTGet14 := CTOD('  /  /    ')
		cTGet15 := dDataBase
		cTGet16 := space(9)
		cTGet19 := SA1->A1_CODPAIS
		cTGet20 := SA1->A1_PAIS
	*/	
		EndIf
	EndIf

	RestArea(aArea)
Return .T.

/*/{Protheus.doc} VLDCPF
Verifica se o CPF informado já existe na base de dados.
@author Douglas Telles
@since 08/03/2016
@version 1.0
@param lCampo, logico, Verifica se a validação está sendo efetuada pelo campo para atualizar informações.
/*/
Static Function VLDCPF(lCampo)

	Local aArea 	:= getarea()

	DEFAULT lCampo	:= .F.

	If oTGet17:nAt == 1 // Estrangeiro - Nao
		If Empty(cTGet1) .And. !(lCampo)
			MSGINFO("Campo Vazio: CPF")
			Return .F.
		EndIf
	
		If !(Empty(cTGet1))
			If !CGC(alltrim(cTGet1))
				RestArea(aArea)
				Return .F.
			EndIf
		EndIf
	
		dbselectarea("SA1")
		dbsetorder(3)
		If lCampo .And. dbseek(xFilial()+cTGet1)
		//cTGetCod:= SA1->A1_COD
			cTGetCod:= SA1->A1_XIDRETA
			cTGet2	 := SA1->A1_NOME
			cTGet3	 := SA1->A1_CEP
			cTGet4	 := SA1->A1_END
			cTGet6	 := SA1->A1_COMPLEM
			cTGet7	 := SA1->A1_BAIRRO
			cTGet8   := SA1->A1_MUN
			cTGet9	 := SA1->A1_EST
			cPessoa  := SA1->A1_PESSOA
			cTGet11  := SA1->A1_TEL
			cTGet13  := SA1->A1_EMAIL
			cTGet14  := SA1->A1_DTNASC
			cTGet15  := SA1->A1_DTINIV
			cTGet16  := SA1->A1_PFISICA
			cTGet19  := SA1->A1_CODPAIS
			cTGet20  := SA1->A1_PAIS
			lEditCli := .F.
		
		ElseIf lCampo .And. !(dbseek(xFilial()+cTGet1))
			cTGet2	 := space(TamSx3("A1_NOME")[1])
			cTGet3	 := space(TamSx3("A1_CEP")[1])
			cTGet4	 := space(TamSx3("A1_END")[1])
			cTGet6	 := space(TamSx3("A1_COMPLEM")[1])
			cTGet7	 := space(TamSx3("A1_BAIRRO")[1])
			cTGet8   := space(TamSx3("A1_MUN")[1])
			cTGet9	 := space(TamSx3("A1_EST")[1])
			cPessoa  := 'F=Fisica'
			cTGet11  := space(TamSx3("A1_TEL")[1])
			cTGet13  := space(TamSx3("A1_EMAIL")[1])
			cTGet14  := CTOD('  /  /    ')
			cTGet15  := dDataBase
			cTGet16  := space(9)
			cTGet19  := SA1->A1_CODPAIS
			cTGet20  := SA1->A1_PAIS
			lEditCli := .T.
		
		EndIf
	EndIf

	RestArea(aArea)
Return .T.

/*/{Protheus.doc} VLDRG
Verifica se o RG informado já existe na base de dados.
@author Douglas Telles
@since 28/03/2016
@version 1.0
@param lCampo, logico, Verifica se a validação está sendo efetuada pelo campo para atualizar informações.
/*/
Static Function VLDRG(lCampo)
	Local cArquivo := GetNextAlias()
	Local cChave
	Local nIndex

	Local aArea := getarea()

	DEFAULT lCampo := .F.

	If oTGet17:nAt == 2 // Estrangeiro - Sim
		If Empty(cTGet16) .And. !(lCampo)
			MSGINFO("Campo Vazio: RG/Passaporte")
			Return .F.
		ElseIf Empty(cTGet16)
			If Select("TSA1") > 0
				TSA1->(dbCloseArea())
			EndIf
		
			cSql:="Select A1_PFISICA From "+RetSqlName('SA1')+" SA1"
			cSql+=" Where A1_PFISICA= '"+cTGet16+"' And A1_FILIAL = '"+xFilial('SA1')+"' "
			cSql+=" And D_E_L_E_T_ = '' "
		
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,csql),"TSA1",.T.,.T.)
	
			If TSA1->(!EOF())
				MsgInfo("Já existe esse Passaporte Cadastrado, Cliente "+SA1->A1_COD+'-'+SA1->A1_LOJA,"Atenção")
				Return
			EndIf
		
			TSA1->(dbCloseArea())
		
		EndIf
	
		While File(cArquivo+GetDbExtension()) // controle para caso o usuario solicite em mais de uma instancias e não causar error.log
			cArquivo := GetNextAlias()
		EndDo
	
		DbSelectArea("SA1")
		cChave := "A1_FILIAL+A1_PFISICA"
	
		IndRegua("SA1",cArquivo,cChave,,,'Pesquisando...',.F.)
	
		If lCampo .And. DbSeek(xFilial('SA1')+cTGet16)
		//cTGetCod:= SA1->A1_COD
			cTGetCod:= SA1->A1_XIDRETA
			cTGet1	 := SA1->A1_CGC
			cTGet2	 := SA1->A1_NOME
			cTGet3	 := SA1->A1_CEP
			cTGet4	 := SA1->A1_END
			cTGet6	 := SA1->A1_COMPLEM
			cTGet7	 := SA1->A1_BAIRRO
			cTGet8  := SA1->A1_MUN
			cTGet9	 := SA1->A1_EST
			cPessoa := SA1->A1_PESSOA
			cTGet11 := SA1->A1_TEL
			cTGet13 := SA1->A1_EMAIL
			cTGet14 := SA1->A1_DTNASC
			cTGet15 := SA1->A1_DTINIV
			lEditCli:= .F.
		ElseIf lCampo .And. !(DbSeek(xFilial('SA1')+cTGet16))
			cTGet1  := space(TamSx3("A1_CGC")[1])
			cTGet2	 := space(TamSx3("A1_NOME")[1])
			cTGet3	 := space(TamSx3("A1_CEP")[1])
			cTGet4	 := space(TamSx3("A1_END")[1])
			cTGet6	 := space(TamSx3("A1_COMPLEM")[1])
			cTGet7	 := space(TamSx3("A1_BAIRRO")[1])
			cTGet8  := space(TamSx3("A1_MUN")[1])
			cTGet9	 := space(TamSx3("A1_EST")[1])
			cPessoa := 'F=Fisica'
			cTGet11 := space(TamSx3("A1_TEL")[1])
			cTGet13 := space(TamSx3("A1_EMAIL")[1])
			cTGet14 := CTOD('  /  /    ')
			cTGet15 := dDataBase
			lEditCli:= .T.
		EndIf
	EndIf

	RetIndex("SA1")
	FErase(cArquivo+OrdBagExt())

	RestArea(aArea)
Return .T.

/*/{Protheus.doc} VLDMUN
Verifica se o município informado existe no cadastro de municipios.
@author Douglas Telles
@since 08/03/2016
@version 1.0
@return lRet, Indica se o municipio existe no cadastro de municipios.
/*/
Static Function VLDMUN()
	Local lRet := .F.
	Local aArea := getarea()

	DbSelectArea("CC2")
	DbSetOrder(4) // FILIAL + ESTADO + MUNICIPIO
	If DbSeek(xFilial("CC2")+Upper(AllTrim(cTGet9))+Upper(FwNoAccent(AllTrim(cTGet8))))
		lRet := .T.
	Else
		MsgInfo("Municipio nao existe no cadastro.")
	Endif

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} AtuObrig
Ajusta a tela caso o cliente seja ou não estrangeiro.
@author Douglas Telles
@since 28/03/2016
@version 1.0
@param oDlg, objeto, Obejto que esta apresentando a tela de cadastro do cliente.
/*/
Static Function AtuObrig(oDlg)
	oTSay1:setText('')
	oTSay16:setText('')
	oTSay1:CtrlRefresh()
	oTSay16:CtrlRefresh()

	If oTGet17:nAt == 2 // Estrangeiro - Sim
		oTSayCod	:= TSay():Create(oDlg,{||'ID Retail:'},15,09,,,,,,.T.,CLR_RED,,200,20)
		oTSay1		:= TSay():Create(oDlg,{||'CPF*:'},15,110,,,,,,.T.,,,200,20)
		oTSay16		:= TSay():Create(oDlg,{||'RG/Passaporte:'},15,200,,,,,,.T.,CLR_RED,,200,20)
	
	Else // Estrangeiro - Nao
		oTSayCod	:= TSay():Create(oDlg,{||'ID Retail:'},15,09,,,,,,.T.,CLR_RED,,200,20)
		oTSay1		:= TSay():Create(oDlg,{||'CPF*:'},15,110,,,,,,.T.,CLR_RED,,200,20)
		oTSay16		:= TSay():Create(oDlg,{||'RG/Passaporte:'},15,200,,,,,,.T.,,,200,20)
	
	EndIf
	oTSayCod:CtrlRefresh()
	oTSay1:CtrlRefresh()
	oTSay16:CtrlRefresh()
Return .T.

/*/{Protheus.doc} VERCEP
Função intermediária que atualiza os dados conforme CEP informado.
@author Douglas Telles
@since 08/03/2016
@version 1.0
@param cCep, caracter, CEP a ser consultado.
@return lRet, Indica se o CEP foi encontrado.
/*/
Static Function VERCEP(cCep)
	Local lRet	:= .T.
	Local aDados	:= {}

	If !Empty(cCep)
		aDados := VLDCEP(cCep,@lRet)
	
		If !lRet
			Return(.T.)
		Endif
	
	/*
	aDados[1] BAIRRO
	aDados[2] CIDADE
	aDados[3] COMPLEMENTO
	aDados[4] COMPLEMENTO 2
	aDados[5] ENDERECO
	aDados[6] UF
	*/
		If !EMPTY(aDados)
			cTGet7 := AvKey(aDados[1],"A1_BAIRRO")
			cTGet8	:= AvKey(aDados[2],"A1_MUN")
			cTGet6	:= AvKey(AllTrim(aDados[3])+" "+AllTrim(aDados[4]),"A1_COMPLEM")
			cTGet4	:= AvKey(AllTrim(aDados[5]),"A1_END")
			cTGet9 := Avkey(aDados[6],"A1_EST")
		Else
			MsgInfo("Cep não Encontrado!")
			lRet := .F.
		EndIf
	EndIf
Return(lRet)

/*/{Protheus.doc} VLDCEP
Comunicação Webservice para consultar o CEP.
@author Douglas Telles
@since 08/03/2016
@version 1.0
@param cCep, caracter, CEP a ser consultado no Webservice.
@param lRet, logico, Indica se foi possível efetuar a conexão para a consulta do CEP.
@return aDados, Array com as informações do CEP consultado.
/*/
Static Function VLDCEP(cCep,lRet)
	Local aDados		:= {}
	Local cXmlRet		:= ""
	Local lRet			:= .T.
	Local cUrl			:= AllTrim(GetMv("SY_URLCEP",,""))
	Local aHeadOut	:= {}
	Local cHeadRet	:= ""
	Local cSoap		:= ""
	Local cErroMsg	:= ""

	Private cErro  := ""
	Private cAviso := ""
	Private oXml

	CursorWait()

/*
* HttpPost( < cUrl >, [ cGetParms ], [ cPostParms ], [ nTimeOut ], [ aHeadStr ], [ @cHeaderGet ] )
* cUrl 		-> Indica o endereço HTTP com a pasta e o documento solicitado.
* cGetParms 	-> Indica uma string de parametros, do tipo GET, que serao enviados ao servidor HTTP atraves da URI.
* cPostParms -> Indica uma string de parametros, do tipo POST, que serao enviados ao servidor HTTP atraves da URL.
* nTimeOut	-> Indica o tempo, em segundos, maximo de inatividade permitido durante a recepcao do documento.
* aHeadStr	-> Indica o array que contem as strings que serao acrescentadas no header da requisicao HTTP a ser realizada.
* cHeaderGet -> Indica a string que contera o header de resposta HTTP enviado pelo servidor requisitado.
*/

	cSoap := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" '
	cSoap += 						'xmlns:cli="http://cliente.bean.master.sigep.bsb.correios.com.br/">'
	cSoap +=   '<soapenv:Header/>'
	cSoap +=   '<soapenv:Body>'
	cSoap +=      '<cli:consultaCEP>'
	cSoap +=         '<cep>'+cCep+'</cep>'
	cSoap +=      '</cli:consultaCEP>'
	cSoap +=   '</soapenv:Body>'
	cSoap += '</soapenv:Envelope>'

	aadd(aHeadOut,'Content-Type: text/xml; charset=' + "utf-8" )
	aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+'; '+'ADVPL WSDL Client 1.060117'+')')

	cXmlRet := HttpPost(cUrl,'',cSoap,,aHeadOut,@cHeadRet)

	If Empty(cXmlRet)
		lRet := .F.
		CursorArrow()
	EndIf

	If lRet .AND. (Len(cXmlRet) < 100)
		lRet := .F.
		CursorArrow()
	EndIf

	If lRet
		oXml := XmlParser(cXmlRet,"_",@cErro,@cAviso)
	EndIf

	If lRet .AND. (oXml == NIL )
		lRet := .F.
		CursorArrow()
	Else
		If lRet .And. Type('oXml:_SOAP_ENVELOPE:_SOAP_BODY:_SOAP_FAULT') == 'O'
			lRet := .F.
			cErroMsg := "CEP NÃO ENCONTRADO. DIGITE OS DADOS MANUALMENTE."
			CursorArrow()
		ElseIf lRet .And. Type('oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS2_CONSULTACEPRESPONSE') == 'O'
			aadd(aDados,oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS2_CONSULTACEPRESPONSE:_RETURN:_BAIRRO:TEXT)
			aadd(aDados,oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS2_CONSULTACEPRESPONSE:_RETURN:_CIDADE:TEXT)
			aadd(aDados,oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS2_CONSULTACEPRESPONSE:_RETURN:_COMPLEMENTO:TEXT)
			aadd(aDados,oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS2_CONSULTACEPRESPONSE:_RETURN:_COMPLEMENTO2:TEXT)
			aadd(aDados,oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS2_CONSULTACEPRESPONSE:_RETURN:_END:TEXT)
			aadd(aDados,oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS2_CONSULTACEPRESPONSE:_RETURN:_UF:TEXT)
		
			CursorArrow()
		Else
			lRet := .F.
			CursorArrow()
		EndIf
	EndIf

	If !lRet
		If Empty(cErroMsg)
			cErroMsg := "Consulta de CEP indisponível. Por Favor, verifique a conexão com a internet. DIGITE OS DADOS MANUALMENTE."
		EndIf
		MsgStop(cErroMsg)
	EndIf
Return(aDados)

/*/{Protheus.doc} STICodeGenerator
Gera o codigo do cliente a partir do CPF/CNPJ.
@author Douglas Telles
@since 08/03/2016
@version 1.0
@param cCGC, caracter, CPF a ser codificado.
@return cRetorno, CPF codificado.
/*/
Static Function STICodeGenerator(cCGC)

	Local nTamCod		:= TamSx3("A1_COD")[1]	//Tamanho do campo
	Local cRetorno 	:= Space(nTamCod)			//Retorno da funcao
	Local nDiv			:= 0                    	//Numero utilizado para geracao do A1_COD
	Local nResto		:= 0                    	//Guarda o resto da divisao
	Local cNumero		:= ""						//Numero gerado

	If !Empty(cCGC)
	
		If Len(AllTrim(cCGC)) > 11
		//Pessoa Juridica
			nDiv := Val(SubStr(cCGC,1,12))
		Else
		//Pessoa Fisica
			nDiv := Val(SubStr(cCGC,1,9))
		EndIf
	
	//Calcula codigo
		While nDiv >= 35 .AND. Len(AllTrim(cNumero)) < nTamCod
		//Pega o inteiro do resto da divisao
			nResto := int(nDiv % 35)
		//Pega o valor inteiro da divisao
			nDiv := int(nDiv / 35)
			cNumero := AllTrim(IIf(nResto < 10, Str(nResto), Chr(nResto + 55))) + AllTrim(cNumero)
		EndDo
	
		If Len(AllTrim(cNumero)) < nTamCod .AND. nDiv > 0
			cNumero := AllTrim(IIf(nDiv < 10, Str(nDiv), Chr(nDiv + 55))) + AllTrim(cNumero)
		EndIf
	
		cRetorno := Replicate("0", nTamCod - Len(AllTrim(cNumero))) + AllTrim(cNumero)
	EndIf
Return cRetorno

/*/{Protheus.doc} TUDOOK
Verifica se todas as informações obrigatórias foram informadas.
@author Douglas Telles
@since 08/03/2016
@version 1.0
@return lRet, Indica se todos os campos obrigatórios foram preenchidos.
/*/
Static Function TUDOOK()
	Local lRet	:= .T.

	lRet := IIF(oTGet17:nAt == 2, VLDRG(), VLDCPF()) // 1=Estrangeiro-Nao, 2=Estrangeiro-Sim

	If lRet
		If Empty(cTGet2)
			MsgInfo("Campo Vazio: Nome")
			lRet 	:= .F.
		EndIf
	EndIf

	If lRet
		If Empty(cTGet3)
			MsgInfo("Campo Vazio: Cep")
			lRet 	:= .F.
		EndIf
	EndIf

	If lRet
		If Empty(cTGet4)
			MsgInfo("Campo Vazio: Endereço")
			lRet 	:= .F.
		EndIf
	EndIf

	If lRet
		If Empty(cTGet8)
			MsgInfo("Campo Vazio: Município")
			lRet 	:= .F.
		EndIf
	EndIf

	If lRet
		If Empty(cTGet7)
			MsgInfo("Campo Vazio: Bairro")
			lRet 	:= .F.
		EndIf
	EndIf

	If lRet
		If Empty(cTGet9)
			MsgInfo("Campo Vazio: Estado")
			lRet 	:= .F.
		EndIf
	EndIf
Return(lRet)

/*/{Protheus.doc} SYCONRET
Efetua a conexão com a Retaguarda para efetuar o cadastro do cliente.
@author Douglas Telles
@since 29/03/2016
@version 1.0
@param aDados, array, Informações que serão utilizadas no cadastro do cliente.
@return aRet, Indica se inclusão foi efetuada com sucesso e a mensagem do resultado.
/*/
Static Function SYCONRET(aDados)
	Local aRet	:= {.F.,'',{}}
	Local aAux	:= {}

// Prepara ambiente para conexao na Retaguarda
	cIP			:= GetMv("MV_LJILLIP",    .F. )// '177.188.240.191  | IP EXTERNO'
	nPorta		:= val(GetMv("MV_LJILLPO",.F.))// '8993 			| PORTA TCP'
	cAmbiente	:= GetMv("MV_LJILLEN",    .F. )// 'teste_loja 		| environment'

// Conecta no ambiente
	oRpcSrv := TRpc():New( cAmbiente )
	If ( oRpcSrv:Connect( cIP, nPorta ) )
	
	// Executa o ExecAuto na retaguarda
		aAux := oRpcSrv:CallProc('U_SYINCCLI', cEmpAnt, cFilAnt, aDados)
	
		If aAux == Nil
			aRet[1] := .F.
			aRet[2] := "Ocorreu um erro inesperado na Retaguarda! "
		Else
			aRet[1] := aAux[1]
		
			If aRet[1]
				aRet[2] := "Cliente cadastrado com sucesso!."
				aRet[3] := {aAux[2],aAux[3]} // lInc, aDados
			Else
				aRet[2] := "O cliente não pôde ser cadastrado na Retaguarda! "
			EndIf
		EndIf
	
	// Fecha conexao
		oRpcSrv:Disconnect()
	Else
		aRet[2] := "Não há conexão com a Retaguarda."
	EndIf
Return aRet

/*/{Protheus.doc} SYINCCLI
Efetua a inclusão do cadastro do cliente na Retaguarda.
@author Douglas Telles
@since 28/03/2016
@version 1.0
@param cEmpEnv, caracter, Empresa para conexão do ambiente.
@param cFilEnv, caracter, Filial para conexão do ambiente.
@param aDados, array, Dados para inclusão do cliente.
@return aRet, Indica se o cliente foi incluído com sucesso, array e opção utilizados no ExecAuto.
/*/
User Function SYINCCLI(cEmpEnv, cFilEnv, aDados)
	Local aRet		:= {.F.,.T.,{}}
	Local nX		:= 0
	Local cQuery	:= ""
	Local cConOut	:= ""
	Local lInc
	Local lEstr
	Local TRB01

	RPCSetType(3)

	PREPARE ENVIRONMENT EMPRESA cEmpEnv FILIAL cFilEnv TABLES 'SA1' MODULO 'COM'

	Conout("Iniciou o cadastro de cliente pelo PDV.")

	lEstr := aDados[31] // 1=Estrangeiro-Nao, 2=Estrangeiro-Sim
	TRB01 := GetNextAlias()

	If !(lEstr)
		DbSelectArea("SA1")
		Dbsetorder(1) // FILIAL + COD + LOJA
		If DbSeek(aDados[1]+aDados[2]+aDados[3])
			lInc := .F.
			aDados[2] := SA1->A1_COD
			aDados[3] := SA1->A1_LOJA
			Conout("O cliente ja existe e sera alterado.")
		Else
			DbSetOrder(3) // FILIAL + CGC
			If DbSeek(aDados[1]+aDados[5])
				lInc := .F.
				aDados[2] := SA1->A1_COD
				aDados[3] := SA1->A1_LOJA
				Conout("O cliente ja existe e sera alterado.")
			Else
				lInc := .T.
				Conout("O cliente nao existe e sera incluido.")
			EndIf
		EndIf
		DbCloseArea()
	Else
		cQuery := "SELECT "+ CRLF
		cQuery += "	A1_COD "+ CRLF
		cQuery += "	A1_LOJA "+ CRLF
		cQuery += "FROM " + RetSqlName("SA1") + " SA1 "+ CRLF
		cQuery += "WHERE "+ CRLF
		cQuery += "	SA1.A1_FILIAL = '" + aDados[1] + "' "+ CRLF
		cQuery += "	AND SA1.A1_PFISICA = '" + aDados[30] + "' "+ CRLF
		cQuery += "	AND SA1.D_E_L_E_T_ = ' ' "+ CRLF
	
		If Select(TRB01) > 0
			DbCloseArea()
		EndIf
	
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),TRB01,.T.,.T.)
	
		(TRB01)->(DbGoTop())
		If !(EOF())
			lInc := .F.
			aDados[2] := (TRB01)->A1_COD
			aDados[3] := (TRB01)->A1_LOJA
			Conout("O cliente ja existe e sera alterado.")
		Else
			lInc := .T.
			Conout("O cliente nao existe e sera incluido.")
		EndIf
	
		DbCloseArea()
	EndIf

// Ajusta informacoes para estrangeiro
	If lEstr
		Conout("Iniciou a preparacao de dados para cliente estrangeiro.")
		aDados[2]	:=	GetSxeNum("SA1","A1_COD")
		aDados[16]	:= 'EX'
		aDados[18]	:= '99999'
		aDados[22]	:= '994'
		aDados[24]	:= '03867'
		aDados[21]	:= 'X'
		Conout("Finalizou a preparacao de dados para cliente estrangeiro.")
	EndIf

	If lInc
		Conout("Iniciou a inclusao do cliente.")
		Reclock("SA1",.T.)
		SA1->A1_FILIAL	:= aDados[1]
		SA1->A1_COD		:= aDados[2]
		SA1->A1_LOJA		:= aDados[3]
		SA1->A1_DTINIV	:= CTOD(aDados[4])
		SA1->A1_CGC		:= aDados[5]
		SA1->A1_PFISICA	:= aDados[30]
	Else
		Conout("Iniciou a alteracao do cliente.")
		DbSelectArea("SA1")
		Dbsetorder(1) // FILIAL + COD + LOJA
		DbSeek(aDados[1]+aDados[2]+aDados[3])
		Reclock("SA1",.F.)
	EndIf
	SA1->A1_NOME		:= aDados[6]
	SA1->A1_NREDUZ		:= aDados[7]
	SA1->A1_CEP		:= aDados[8]
	SA1->A1_END		:= aDados[9]
	SA1->A1_COMPLEM	:= aDados[10]
	SA1->A1_BAIRRO		:= aDados[11]
	SA1->A1_TEL		:= aDados[12]
	SA1->A1_EMAIL		:= aDados[14]
	SA1->A1_DTNASC		:= CTOD(aDados[15])
	SA1->A1_EST		:= aDados[16]
	SA1->A1_MUN		:= aDados[17]
	SA1->A1_COD_MUN	:= aDados[18]
	SA1->A1_PESSOA		:= aDados[19]
	SA1->A1_INSCR		:= aDados[20]
	SA1->A1_TIPO		:= aDados[21]
	SA1->A1_PAIS		:= aDados[22]
	SA1->A1_GRPTRIB	:= aDados[23]
	SA1->A1_CODPAIS	:= aDados[24]
	SA1->A1_MSBLQL		:= aDados[25]
	SA1->A1_TIPCLI		:= aDados[26]
	SA1->A1_TIPOCLI	:= aDados[27]
	SA1->A1_SITUA		:= aDados[28]
	SA1->A1_XIDRETA	:= aDados[32]

	If AllTrim(SA1->A1_PESSOA) == "F"
		SA1->A1_CONTRIB	:= "2"
	EndIf

	MsUnlock()
	Conout("Finalizou a inclusao/alteracao do cliente.")

	cConOut := "Codigo        -> " + aDados[2]  + CRLF
	cConOut += "Loja          -> " + aDados[3]  + CRLF
	cConOut += "CPF           -> " + aDados[5]  + CRLF
	cConOut += "RG/Passaporte -> " + aDados[30] + CRLF

	Conout(cConOut)

	aRet[1] := .T.
	aRet[2] := lInc
	aRet[3] := aDados

	RpcClearEnv()
Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscaCep
Função para buscar o CEP, via webserce com retorno em JSON.
@author     Jerfferson Silva
@since      15.03.2019
@version	1.0
@param      cCEP, caracter, Cep sem o '-' apenas os numeros.
/*/
//-------------------------------------------------------------------
User Function fBuscaCep(cCEP)

	Local cUrl			:= "http://viacep.com.br/ws/"
	Local cGetParams	:= ""
	Local nTimeOut		:= 200
	Local aHeadStr		:= {"Content-Type: application/json"}
	Local cHeaderGet	:= ""
	Local cRetWs		:= ""
	Local oObjJson		:= Nil
	Local cStrResul	:= ""

	If fValidarCep(cCep,@cUrl)
		cRetWs	:= HttpGet(cUrl, cGetParams, nTimeOut, aHeadStr, @cHeaderGet)
		
		If !FWJsonDeserialize(cRetWs, @oObjJson)
			MsgStop("Ocorreu erro no processamento do Json.")
			Return Nil
		
		ElseIf AttIsMemberOf(oObjJson,"ERRO")
			MsgStop("CEP inexistente na base de dados.")
			Return Nil
		Else
			cTGet7 := AvKey(DecodeUTF8(oObjJson:bairro),"A1_BAIRRO")
			cTGet8	:= AvKey(DecodeUTF8(oObjJson:localidade),"A1_MUN")
			cTGet6	:= AvKey(DecodeUTF8(oObjJson:complemento),"A1_COMPLEM")
			cTGet4	:= AvKey(AllTrim(DecodeUTF8(oObjJson:logradouro)),"A1_END")
			cTGet9 := Avkey(DecodeUTF8(oObjJson:uf),"A1_EST")
		EndIf
	EndIf
Return (cStrResul)
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} fValidarCep
Função para validação do cep
@author     Jerfferson Silva
@since      15.03.2019
@param 		cCep, caracter, Cep pra consulta
@param 		cUrl, caracter, Url do serviço
@return 	lRet, logico, Retorno .T. (true) se cep valido ou .F. (false) se invalido.
/*/
//-------------------------------------------------------------------------------------
Static Function fValidarCep(cCep,cUrl)
	Local lRet := .F.
	
	If Empty(Alltrim(cCep)) //Validar se foi passado conteudo é vazio.
		MsgStop("Favor informar o CEP.")
		Return (lRet)
	
	ElseIf Len(Alltrim(cCep)) < 8 //Validar se o CEP informado tem menos 8 digitos.
		MsgStop("O CEP informado não contem a quantidade de dígito correta, favor informe um CEP válido.")
		Return (lRet)
	
	ElseIf At("-",cCep,) > 0 //Validar se o CEP está separado por "-".
		If Len(StrTran(AllTrim(cCep),"-")) == 8 //Validar se o CEP informado tem 8 digitos.
			cUrl += StrTran(AllTrim(cCep),"-")+"/json/"
			lRet := .T.
		Else
			MsgStop("O CEP informado não contem a quantidade de dígito correta, favor informe um CEP válido.")
			Return (lRet)
		EndIf
	Else
		cUrl += AllTrim(cCep)+"/json/"
		lRet := .T.
	EndIf
Return (lRet)