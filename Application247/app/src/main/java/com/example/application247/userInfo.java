package com.example.application247;

public class userInfo {

    private String userFname;
    private String userLname;
    private String userAddress;
    private String userContact;
    private String userEmail;


    // this is an empty constructor, important when using databases
    public  userInfo(){

    }


    //set up getter and setter
    public String getUserFname(){
        return userFname;
    }
    public void setUserFname(String userFname){
        this.userFname = userFname;
    }

    public String getUserLname(){
        return userLname;
    }
    public void setUserLname(String userLname){
        this.userLname = userLname;
    }

    public String getUserAddress(){
        return  userAddress;
    }

    public void setUserAddress(String userAddress){
        this.userAddress = userAddress;
    }
    public String getUserContact(){return  userContact;}
    public void setUserContact(String userContact){ this.userContact = userContact;}
    public String getUserEmail(){return  userEmail;}
    public void setUserEmail(String userEmail){this.userEmail = userEmail;}
}
