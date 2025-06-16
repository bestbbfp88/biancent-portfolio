package com.example.application247;

public class User_android {

    String name, reqtype, pnum, location;


    public User_android(){}

    public User_android(String name, String reqtype, String pnum, String location) {
        this.name = name;
        this.reqtype = reqtype;
        this.pnum = pnum;
        this.location = location;

    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getReqtype() {
        return reqtype;
    }

    public void setReqtype(String reqtype) {
        this.reqtype = reqtype;
    }

    public String getPnum() {
        return pnum;
    }

    public void setPnum(String pnum) {
        this.pnum = pnum;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }
}
