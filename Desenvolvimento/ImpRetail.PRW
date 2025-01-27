#INCLUDE "totvs.ch"
/*----------------------------------------------------------------------------*
* Programa: RFISM01     Autor: Oscar Lira             Data:  03/03/17         *
* Descricao: Rotina para leitura de importacao de arquivo .CSV contendo as TES*
*            que serao modificadas                                            *
*            a estrutura do arquivo tem que ser a seguinte:                   *
*   1           2              3                  4             5          6          7          8            9          10                 11
* filial;numero da nota;codigo do produto;codigo do fornecedor;cfop;tes original;tes correta;cst original;cst correta;codigo BCC;codigo do centro de custos
*----------------------------------------------------------------------------*/
User Function ImpRetail()
Private cArquivo := tFileDialog( "CSV files (*.csv)","Arquivo para importação",,,.F.)

If !Empty(cArquivo) .and. FWAlertYesNo("Confirma a importação do código retail para o cadastro de clientes e de fornecedores?")
    Processa({|| ProcRetail()},"")
EndIf

Return Nil
/*---------------------------------------------------------------------------*/
Static Function ProcRetail()
Local aDados := {}
Local cLinha   := ""
Local nHandle  := Ft_Fuse(cArquivo)

If nHandle == -1
    FWAlertError("Arquivo "+cArquivo+" não encontrado")
   Return Nil
EndIf

SA1->(dBSetorder(3))  // A1_FILIAL+A1_CGC
SA2->(dBSetorder(3))  // A2_FILIAL+A2_CGC

Ft_FGoTop()
ProcRegua(FT_FLastRec())
FT_FGoTop()

Do While !Ft_FEof()
    IncProc()
    cLinha := Ft_FReadLn()
    aDados := STRTOKARR( cLinha, ";")
    If Alltrim(aDados[1]) <> "Codigo"
        If SA1->(MsSeek(xFilial("SA1")+aDados[3]))
            RecLock("SA1",.F.)
            SA1->A1_XIDRETA := aDados[4]
            SA1->(MsUnlock())
        EndIf
        If SA2->(MsSeek(xFilial("SA2")+aDados[3]))
            RecLock("SA2",.F.)
            SA2->A2_XIDRETA := aDados[4]
            SA2->(MsUnlock())
        EndIf
    EndIf

    FT_FSkip()
EndDo
FT_FUse()

FWAlertSuccess("Importação concluída")

Return Nil
