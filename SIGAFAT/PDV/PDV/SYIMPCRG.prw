#Include 'PROTHEUS.CH'
#Include 'APWEBSRV.CH'
#Include 'XMLXFUN.CH'
#Include 'TBICONN.CH'

/*/{Protheus.doc} SYIMPCRG
Verifica se existe carga a ser importada e efetua o processo automaticamente.
@author Douglas Telles
@since 21/03/2016
@version 1.0
@param cEmpresa, caracter, Empresa para abrir ambiente
@param cFil01, caracter, Filial para abrir ambiente
@param cIntervalo, caracter, Intervalo de verificação da carga
/*/
User Function SYIMPCRG(cEmpresa,cFil01,cIntervalo)
	Local lLockJob := .F.
	Local cIP
	Local nPorta
	Local cAmbiente
	Local cEmp
	Local cFil
	Local cHorario
	Local aHr

	Default cEmpresa		:= ""
	Default cFil01		:= ""
	Default cIntervalo	:= '600000' // 60000 milisegundos = 1 minuto

	nIntervalo := Val(cIntervalo)

	RPCSetType(3)

	PREPARE ENVIRONMENT EMPRESA cEmpresa FILIAL cFil01

	Conout('[' + DTOC(dDataBase) + ' ' + Time() + "] Iniciou a funcao U_SYIMPCRG (Carga Automatica)")

	While !KillApp()
		cHorario := AllTrim(GetMv("SY_HRIMCRG",,"23:00:00"))

		aHr := Separa(cHorario,'|',.F.)

		// Prepara ambiente para conexao na Retaguarda
		cIP			:= GetMv("MV_LJILLIP",    .F.)//'187.94.60.225'
		nPorta		:= val(GetMv("MV_LJILLPO",.F.))//2218
		cAmbiente	:= GetMv("MV_LJILLEN",    .F. )

		// Conecta no ambiente
		oRpcSrv := TRpc():New( cAmbiente )
		If ( oRpcSrv:Connect( cIP, nPorta ) )
			// Verifica se a carga esta sendo gerada
			lLockJob := oRpcSrv:CallProcEX('U_SYGETMV',cEmpresa,cFil01,'SY_LOCKJOB')

			// Fecha conexao
			oRpcSrv:Disconnect()
		EndIf

		For nX := 1 to len(aHr)
			cHoras	:= Left(aHr[nX],5)

			If Left(Time(),5) == cHoras
				Conout('[' + DTOC(dDataBase) + ' ' + Time() + "] **** Executando U_SYIMPCRG ****")

				If !lLockJob
					cIP			:= GetMv("MV_LJILLIP",    .F.)//'187.94.60.225'
					nPorta		:= val(GetMv("MV_LJILLPO",.F.))//2218
					cAmbiente	:= GetMv("MV_LJILLEN",    .F. )
					cEmp		:= GetMv("MV_LJILLCO", .F.)
					cFil		:= GetMv("MV_LJILLBR", .F.)

					Conout('[' + DTOC(dDataBase) + ' ' + Time() + "] Iniciou a importacao das cargas")

					LOJA1157Job(cIP, nPorta, Rtrim(cAmbiente), cEmp, cFil, .T., .T., .T., .T., .T.)

					Conout('[' + DTOC(dDataBase) + ' ' + Time() + "] Finalizou a importacao das cargas")
				Else
					Conout('[' + DTOC(dDataBase) + ' ' + Time() + "]******************** ATENCAO ********************")
					Conout("A carga nao foi importada pois o processo de geracao de carga automatica esta em execucao na Retaguarda!")
				EndIf
			EndIf
		Next nX
		nStep  := 1
		nCount := nIntervalo/1000

		While !KillApp() .AND. nStep <= nCount
			Sleep(1000) //Sleep de 1 segundo
			nStep++
		EndDo
	EndDo

	Conout('[' + DTOC(dDataBase) + ' ' + Time() + "] Finalizou a funcao U_SYIMPCRG (Carga Automatica)")

	RESET ENVIRONMENT
Return .T.