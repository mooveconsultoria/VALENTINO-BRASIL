#Include 'Totvs.ch'
/******************************************************************************
* Programa: ADFATX01       Oscar Lira - TOTVS IP         26/07/2023           *
* Uso: Utilizado para os usuarios poderem atualizar os parametros de cancela- *
*      mento de notas sem precisar acessar o configurador                     *
******************************************************************************/
User Function VAFATX01()
Local aParamBox	:= {}
Local aRet      := {}

aAdd(aParamBox,{2,"Tipo de atualização","Bloqueio",{"Bloqueio","Tipo","Conta contábil"},60,"",.T.})
aAdd(aParamBox,{6,"Arquivo CSV"        ,Space(150),"","","",80,.F.,"Arquivos .CSV |*.CSV"})

If ParamBox(aParamBox,"Atualização do cadastro de produtos",@aRet,,,.T.,,,,,.F.,.F.)
    Processa({|| AtuCadProd()},If(mv_par01="Bloqueio","Bloqueando produtos",If(mv_par01="Tipo","Alterando o tipo dos produtos","Alterando a conta contábil dos produtos")))
Endif

Return Nil
/*---------------------------------------------------------------------------*/
Static Function AtuCadProd()
Local cLinha   := ""
Local nHandle  := Ft_Fuse(mv_par02)

If nHandle == -1
    FWAlertError("Arquivo "+mv_par02+" não encontrado")
    Return Nil
EndIf

SB1->(dBSetorder(1))  // B1_FILIAL+B1_COD

Ft_FGoTop()
ProcRegua(FT_FLastRec())
FT_FGoTop()

Do While !Ft_FEof()
    IncProc()
    cLinha := Ft_FReadLn()

	// Eliminar todas as ocorrencias de ;; para evitar que o array fique com tamanho menor que a qtd de colunas                                                  ³
	While AT(";;",cLinha) <> 0
		cLinha := StrTran(cLinha,";;","; ;")
	EndDo

    aDados := STRTOKARR( cLinha, ";")
    If Upper(Alltrim(aDados[1])) <> "CODIGO"
        If SB1->(MsSeek(xFilial("SB1")+aDados[1]))
            RecLock("SB1",.F.)
            If mv_par01 = "Bloqueio"
                If Upper(Alltrim(aDados[4])) == "BLOQUEAR"
                    SB1->B1_MSBLQL := "1"
                EndIf
            ElseIf mv_par01 = "Tipo"
                SB1->B1_TIPO := aDados[4]
            Else
                SB1->B1_CONTA := aDados[5]
            EndIf
            SB1->(MsUnlock())
        EndIf
    EndIf

    FT_FSkip()
EndDo
FT_FUse()

FWAlertSuccess("Atualização concluída")

Return Nil
