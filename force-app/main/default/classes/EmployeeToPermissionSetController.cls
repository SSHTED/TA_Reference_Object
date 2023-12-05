/*
 * @Class : EmployeeToPermissionSetController
 *
 * @Method : 
 *
 *	- insertPMSPermssionSet(userId)
 *	- insertITAMPermssionSet(userId)
 * 
 * @Author : hojae-lee
 * @Date : 2022-12-08
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-12-08 | hojae-lee     | 최초작성
 */
global with sharing class EmployeeToPermissionSetController{
    @future
    global static void insertPMSPermssionSet(Id userId){ // Employee 트리거에서, 신규 입사자, PMS 권한(본인)에 삽입 클래스
        System.debug('yes controller!');
        System.debug('PMS본인 라벨은 : ' + System.label.PMS_PERM_PERSON);

        List<PermissionSetAssignment> goPSetList01 = new List<PermissionSetAssignment>();

        List<PermissionSetAssignment> goPSetId01 = [SELECT PermissionSetId
                                                    FROM PermissionSetAssignment
                                                    WHERE PermissionSet.Name = :System.label.PMS_PERM_PERSON // PMS본인으로 변경하기
                                                    AND AssigneeId = :userId
                                                    LIMIT 1];
        System.debug('goPSetId01 ? ' + goPSetId01);
        Id pmsId = [SELECT Id
                    FROM PermissionSet
                    WHERE Name = :System.label.PMS_PERM_PERSON
                    LIMIT 1].Id;

        if(goPSetId01.size() == 0 || goPSetId01 == null){
            System.debug('size 01 ? ' + goPSetId01.size());
            goPSetList01.add(
                new PermissionSetAssignment(
                    AssigneeId = userId
                    , PermissionSetId = pmsId
                )
            );
        }
        insert goPSetList01;

        System.debug('goPSetList01 ? ' + goPSetList01);
    }

    @future
    global static void insertITAMPermssionSet(Id userId){ // Employee 트리거에서, 신규 입사자, ITAM_User에 삽입 클래스
        System.debug('yes controller!');
        System.debug('ITAM_User 라벨은 : ' + System.label.ITAM_User);

        List<PermissionSetAssignment> goPSetList02 = new List<PermissionSetAssignment>();

        List<PermissionSetAssignment> goPSetId02 = [SELECT PermissionSetId
                                                    FROM PermissionSetAssignment
                                                    WHERE PermissionSet.Name = :System.label.ITAM_User // ITAM_User로 변경하기
                                                    AND AssigneeId = :userId
                                                    LIMIT 1];
        System.debug('goPSetId02 ? ' + goPSetId02);
        Id itamId = [SELECT Id
                     FROM PermissionSet
                     WHERE Name = :System.label.ITAM_User
                     LIMIT 1].Id;

        if(goPSetId02.size() == 0){
            System.debug('size 02 ? ' + goPSetId02.size());
            goPSetList02.add(
                new PermissionSetAssignment(
                    AssigneeId = userId
                    , PermissionSetId = itamId
                )
            );
        }
        insert goPSetList02;

        System.debug('goPSetList02 ? ' + goPSetList02);
    }
}