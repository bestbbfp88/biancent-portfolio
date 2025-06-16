/*This Program is used only for keeping the records of the Student. This may contain personal information of the 
student which is protected by law. The data in this application is secured and shall not be deleted once inputted for 
history purposes.

ABOUT THIS PROGRAM

- The data in this application can be tampered but shall be recorded in history
- All data are stored in a permanent data storage, deletion of files might result in data loss
- The user is prohibited from tampering with data through files, as it might result in data loss
- Data loss in this program due to the recklessness of the user shall not be protected by user rights in this program

USER CONDITIONS

- This program is used only for professional use
- Malicious activity in this program can be reported to the developer
- User has the right to put any data in this program
- User is prohibited in tampering the source file, it might result to program error*/

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<conio.h>
#include<ctype.h>
#include<time.h>
#define line 100
#define length 30
#define quiz_S 50
#define stud_s 100
#define c_year 2022
#define l_year 1950

FILE *File; //this file pointer is for Student Information File
FILE *unrl_F;	//this file pointer is used for the highest score in every quiz
FILE *file; //this file pointer is used for the quiz scores

//this is a global variable used in every parts of the code
int count = 0;
int unrl_cnt = 0;
int daycount = 0;
int quiz = 0;

typedef struct{
	char Fname[length];
	char Lname[length];
	char Mid_I[length];
}names;

typedef struct{
	char barangay[length];
	char town_City[length];
	char province[length];
}add;

typedef struct{
	char Month[10];
	int day;
	int year;
}birth;

typedef struct{
	names name_F;
	int id;
	add  address;
	birth Birthday;
	char gender[7]; 
	char enr_time[50];
	char con_num[12];
}student;

typedef struct{
	names P_name;
	add P_add;
	char relation[15];
	char contact_num[12];
}parent_Info;



// this is the declaration in some of the functions in the program
int writeStud_Info();
int read_Info();
void valid_INT_inpt();
int ID_checker();
int validate_Input();
int read_dayCount();
void display_Stud_Info();
void sort();
int write_unenrl();
int read_unrl();
//int ID_checker_unenrl();
int validate_string();
void quickAscending();
void quickSortMain();
void display_Indiv();

void text_boxDesign(){
	int ctr = 0;
	int ctr1 = 0;
	
	for(ctr1 = 0; ctr1 < 5; ctr1++){
		printf("\t");
	}
	printf("        ");
		for(ctr = 0; ctr < 29; ctr++){
			printf("-");
	}
	printf("\n");
}

void toCenter(){
	int ctr = 0;
	
	for(ctr = 0; ctr < 5; ctr++){
		printf("\t");
	}
	printf("          ");
}


void line_design(){
	int ctr = 0;
	printf("\t   ");
	for(ctr = 1; ctr <= 100; ctr++){
		printf("=");
	}
	printf("\n\n");
}

void name(){
	text_boxDesign();
	toCenter();
	printf("   HOLY NAME UNIVERSITY\n");
	text_boxDesign();
	toCenter();
	printf("        THE BEAST\n");
	text_boxDesign();
	toCenter();
	printf("MADE BY:\n");
	toCenter();
	printf("BIANCENT PACATANG\n");
	toCenter();
	printf("JOREME BALIWIS\n");
	text_boxDesign();
	printf("\n");
	toCenter();
	printf("   CCS 104 FINAL PROJECT");

}

void space(){
	int ctr = 0;
	for(ctr = 0; ctr < 5; ctr++){
		printf("\n");
	}
}

void display_Headpage(){
	
	int ctr = 0;
	
	line_design();
	for(ctr = 0; ctr < 4; ctr++){
		printf("\t");
	}
	printf("     | | | | STUDENT RECORD INFORMATION SYSTEM | | | |\n\n");
	line_design();
}

void name_Info(char name_Info[length], char type_Name[length]){
	int result, res;
		do{
			printf("%s:", type_Name);
			fflush(stdin);
			fgets(name_Info, length, stdin);//fgets is used in order to get an input from the user which is a string
	    	name_Info[strcspn(name_Info, "\n")] = 0;//strcpn is used in order to delete the enter key of the fgets function
	    	result = validate_Input(name_Info);
	    	res = validate_string(name_Info);
		}while(result == 0 || res == 1);
}
 
//this function is used for creating an automated ID of the student
void get_Id(student stud_Info[stud_s], int cnt, student unenrl_stud[stud_s]){
	char ID[10];
	int result, res;
	int number;
	int lower = 100000, upper = 999999;
	
	id:
	srand(time(NULL));
	number = (rand() % (upper - lower + 1)) + lower;
	
			result = ID_checker(number, stud_Info);
			res = ID_checker(number, unenrl_stud);
				if(result == -1 || res == -1){
					stud_Info[cnt].id  = number;//if Id did not exist , copy the inputted ID to the id which will input to the file
					time_t date;
					time(&date);
					strcpy(stud_Info[cnt].enr_time, ctime(&date));
					stud_Info[cnt].enr_time[strcspn(stud_Info[cnt].enr_time, "\n")] = 0;
				}else{
					goto id;
				}
}


void address_Info(char barangay[length], char town[length], char province[length]){
	int result = 0, res = 0;
			
			do{
			printf("Barangay: ");
			fflush(stdin);
			fgets(barangay, length, stdin);//fgets is used in order to get an input from the user which is a string
	    	barangay[strcspn(barangay, "\n")] = 0;//strcpn is used in order to delete the enter key of the fgets function
	    	result = validate_Input(barangay);
	    	res = validate_string(barangay);
			}while(result == 0 || res == 1);
			
			do{
			printf("Town: ");
			fflush(stdin);
			fgets(town, length, stdin);//fgets is used in order to get an input from the user which is a string
	    	town[strcspn(town, "\n")] = 0;//strcpn is used in order to delete the enter key of the fgets function
	    	result = validate_Input(town);
	    	res = validate_string(town);
			}while(result == 0 || res == 1);
			
			do{
			printf("Province: ");
			fflush(stdin);
			fgets(province, length, stdin);//fgets is used in order to get an input from the user which is a string
	    	province[strcspn(province, "\n")] = 0;//strcpn is used in order to delete the enter key of the fgets function
	    	result = validate_Input(province);
	    	res = validate_string(province);
			}while(result == 0 || res == 1);
			
}

void month_Info(student stud_Info[stud_s], int cnt){
	 int ctr =0, res=0;
	 char get_Month[10];
	char month[12][12] = {{"JANUARY"}, {"FEBRUARY"}, {"MARCH"}, {"APRIL"}, {"MAY"}, {"JUNE"}, {"JULY"}, {"AUGUST"}, {"SEPTEMBER"}, {"OCTOBER"}, {"NOVEMBER"}, {"DECEMBER"}};
	do{
			printf("Month: ");
			fflush(stdin);
			fgets(get_Month, 12, stdin);//fgets is used in order to get an input from the user which is a string
	    	get_Month[strcspn(get_Month, "\n")] = 0;//strcpn is used in order to delete the enter key of the fgets function
	    	if(strlen(get_Month) > 10){
	    		printf("Characters should not greater than 10\n");
			}else if(strlen(get_Month) < 2){
				printf("Characters should not be less than 2\n");
			}
			
   			 for (int i = 0; get_Month[i] != '\0'; i++) {
     		   get_Month[i] = toupper(get_Month[i]);
   			 }
   			 

			for(ctr = 0; ctr < 12; ctr++){
				if(strcmp(get_Month, month[ctr]) == 0){
					strcpy(stud_Info[cnt].Birthday.Month, get_Month);
					res = 0;
					break;
				}else{
					res = -1;
				}
				}
					
			if(res == -1){
				printf("INVALID MONTH\n");
			}
			}while(strlen(get_Month) > 10 || strlen(get_Month) < 2 || res == -1);
		
}

void day_Info(student stud_Info[stud_s], int cnt){
	int validate;
	do{
			printf("Day: ");
			fflush(stdin);
			validate = scanf("%d", &stud_Info[cnt].Birthday.day);
			
	    	if(stud_Info[cnt].Birthday.day > 31 || stud_Info[cnt].Birthday.day < 1){
	    		printf("Invalid Date\n");
			}else{
				valid_INT_inpt(validate);
			}
 	}while(stud_Info[cnt].Birthday.day > 31 || stud_Info[cnt].Birthday.day < 1 || validate != 1);
}

void year_Info(student stud_Info[stud_s], int cnt){
		int validate;
	do{
			printf("Year: ");
			fflush(stdin);
			validate = scanf("%d", &stud_Info[cnt].Birthday.year);
	    	if(stud_Info[cnt].Birthday.year > c_year || stud_Info[cnt].Birthday.year < l_year){
	    		printf("Invalid Date\n");
			}else{
				valid_INT_inpt(validate);
			} 
	}while(stud_Info[cnt].Birthday.year > c_year || stud_Info[cnt].Birthday.year < l_year || validate != 1);
}
void birth_Info(student stud_Info[stud_s], int cnt){
	int result = 0, ctr, res = 0;

			month_Info(stud_Info, cnt);
			day_Info(stud_Info,  cnt);
			year_Info(stud_Info, cnt);			
}


void gender_Info(student stud_Info[stud_s], int cnt){
	char gend;
	char sex_M[5] = {"Male"}, sex_F[7]= {"Female"};
	int result;

		iterate:
			printf("Gender[M/F]: ");
			fflush(stdin);
			scanf("%c", &gend);
	    	if(toupper(gend)=='M'){
	    		strcpy(stud_Info[cnt].gender, sex_M);
			}else if(toupper(gend)=='F'){
				strcpy(stud_Info[cnt].gender, sex_F);
			}else{
				printf("Invalid Input. Please Input M/F only...\n");
				goto iterate;
			}
}

void contact_num(char cont_num[12]){
	char numbers[10] = {"0123456789"};
	int i, c, res, result, reslt;
	char hold[1];

	back:
	printf("Contact Number: ");
	fflush(stdin);
	gets(cont_num);
	if(strlen(cont_num) != 11){
		printf("Please Input Valid Contact Number\n");
		goto back;
	}
	
   			for (i = 0; i < 11; i++){
	   			for(c= 0; c < 11; c++){
	   				if(cont_num[i] == numbers[c]){
					  res = 1;
					  break;
				   }else{
				   	   res = 0;
				   }
				}
   		 }
   		 
   				if(res == 1){
				}else if(res == 0){
					printf("Please Enter a Number Only\n");
					goto back;
				}
}

void relationship(parent_Info parent[stud_s], int cnt){
	 int ctr =0, res=0;
	 char get_relation[10];
	char relation[7][12] = {{"FATHER"}, {"MOTHER"}, {"GUARDIAN"}, {"SISTER"}, {"BROTHER"}, {"HUSBAND"},{"WIFE"}};
	
	printf("\nRelation Type[Father, Mother, Guardian, Sister, Brother, Husband, Wife]\n");
	do{
			printf("Relationship: ");
			fflush(stdin);
			fgets(get_relation, 12, stdin);//fgets is used in order to get an input from the user which is a string
	    	get_relation[strcspn(get_relation, "\n")] = 0;//strcpn is used in order to delete the enter key of the fgets function
	    	if(strlen(get_relation) > 10){
	    		printf("Characters should not greater than 10\n");
			}else if(strlen(get_relation) < 2){
				printf("Characters should not be less than 2\n");
			}
			
   			 for (int i = 0; get_relation[i] != '\0'; i++) {
     		   get_relation[i] = toupper(get_relation[i]);
   			 }
   			 

			for(ctr = 0; ctr < 7; ctr++){
				if(strcmp(get_relation, relation[ctr]) == 0){
					strcpy(parent[cnt].relation, get_relation);
					res = 0;
					break;
				}else{
					res = -1;
				}
				}
					
			if(res == -1){
				printf("INVALID RELATION TYPE\n");
			}
		}while(strlen(get_relation) > 10 || strlen(get_relation) < 2 || res == -1);
		
}


//this function is for the unenrollment of the student
int unenroll(student stud_Info[stud_s], student unenrl_stud[stud_s], parent_Info parent[stud_s], parent_Info emgncy_Info[stud_s]){
	int cnt, ctr, cnts, result, id_num, validate; 
	cnt = read_Info(stud_Info, parent); 
	read_unrl(unenrl_stud, emgncy_Info);
	if(cnt == -1){
		printf("NO FILE\n");
	}else{
		get_id:
			printf("ID Number >> ");
			 fflush(stdin);
			 validate = scanf("%d", &id_num);
			 if(validate != 1){
			 	printf("INVALID ID NUMBER\n");
			 	getch();
			 	goto get_id;
			 }
			 result = ID_checker(id_num, stud_Info);
			 if(result == -1){
			 	printf("ID NOT FOUND\n");
			 	getch();
			 }else{
				
					if(cnt < 1 && cnts < 1){
						printf("\n\n===================\n"); 
						printf("     UNENROLL\n");
						printf("===================\n");
						printf("USAGE IS UNAVAILABLE DUE TO LACK OF DATA!!\n");	
						getch();
					}else{
						unenrl_stud[unrl_cnt] = stud_Info[result];
						emgncy_Info[unrl_cnt] = parent[result];
						time_t date;
						time(&date);
						strcpy(unenrl_stud[unrl_cnt].enr_time, ctime(&date));
						unenrl_stud[unrl_cnt].enr_time[strcspn(unenrl_stud[unrl_cnt].enr_time, "\n")] = 0;
						unrl_cnt++;
						write_unenrl(unenrl_stud, emgncy_Info);
						
						for(ctr = result; ctr < cnt-1; ctr++){
							stud_Info[ctr] = stud_Info[ctr+1];
							parent[ctr] = parent[ctr+1];
						}
						count--;
						writeStud_Info(stud_Info,parent);	
						printf("Student Unenrolled Sucessfully\n");	
						getch();
						}
				}
	}
}

//this function is used to add new student
void addStudent(student stud_Info[stud_s], student unenrl_stud[stud_s], parent_Info parent[stud_s]){
	int validate, studnum, ctr = 0, result = 0, cnt = 0, quiz_cnt, ans;
	char first_name[15] = {"First Name"}, last_name[15] = {"Last Name"}, middle_name[15] = {"Middle Name"};
	char ID[10], key;
	count = read_Info(stud_Info);
		if(count == -1){
			printf("NO FILE\n");
		}
		printf("\nPROCEED[Y] >> ");
		ans=getche();
		ans=toupper(ans);
		switch(ans){
			case 'Y':
				system("CLS");
					display_Headpage();
					printf("\nSTUDENT INFORMATION\n\n");
			
					printf("Full Name\n");
					name_Info(stud_Info[count].name_F.Lname, last_name);
					name_Info(stud_Info[count].name_F.Fname, first_name);
					name_Info(stud_Info[count].name_F.Mid_I, middle_name);
					printf("\nAddress\n");
					address_Info(stud_Info[count].address.barangay, stud_Info[count].address.town_City, stud_Info[count].address.province);
					printf("\nBirthday\n");
					birth_Info(stud_Info, count);
					printf("\nContact Number\n");
					contact_num(stud_Info[count].con_num);
					printf("\nGender\n");
					gender_Info(stud_Info, count);
					//This section is for the emergency information
					printf("\n-----------------------------");
					printf("\nEmergency Information\n");
					relationship(parent, count);
					printf("\nFull Name\n");
					name_Info(parent[count].P_name.Lname, last_name);
					name_Info(parent[count].P_name.Fname, first_name);
					name_Info(parent[count].P_name.Mid_I, middle_name);
					printf("\nContact Number\n");
					contact_num(parent[count].contact_num);
					printf("\nAddress\n");
					address_Info(parent[count].P_add.barangay, parent[count].P_add.town_City, parent[count].P_add.province);
					//End of Information
					get_Id(stud_Info, count, unenrl_stud);
						system("CLS"); 
						display_Stud_Info(count, stud_Info, parent);
						printf("\n");
						printf("\t   STUDENT ENROLLED SUCCESSFULLY\n");
						getch();
						++count;
						writeStud_Info(stud_Info, parent);
			default:
				break;
		}
	}

//this will add the existing student	
void add_exist_stud(student stud_Info[stud_s], student unenrl_stud[stud_s], parent_Info parent[stud_s], parent_Info emgncy_Info[stud_s]){
	int id_num, result, validate, cnt, cntr, ctr;
	cnt = read_Info(stud_Info, parent);
	cntr = read_unrl(unenrl_stud, emgncy_Info);
	get_id:
	 printf("ID Number >> ");
	 fflush(stdin);
	 validate = scanf("%d", &id_num);
	 if(validate != 1){
	 	printf("INVALID CODE\n");
	 	goto get_id;
	 }
	 result = ID_checker(id_num, unenrl_stud);
	 if(result == -1){
	 	printf("ID NOT FOUND\n");
	 }else{
	 	
	 	stud_Info[cnt] = unenrl_stud[result];
	 	parent[cnt] = emgncy_Info[result];
	 	time_t date;
		time(&date);
		strcpy(stud_Info[cnt].enr_time, ctime(&date));
		stud_Info[cnt].enr_time[strcspn(stud_Info[cnt].enr_time, "\n")] = 0;
	 	++count; 
	 	writeStud_Info(stud_Info, parent);
	 	
	 	for(ctr = result; ctr < cntr-1; ctr++){
					unenrl_stud[ctr] = unenrl_stud[ctr+1];
					emgncy_Info[ctr] = emgncy_Info[ctr+1];
				}
			unrl_cnt--;
			write_unenrl(unenrl_stud, emgncy_Info);	
			printf("STUDENT RE-ENROLLED SUCCESSFULLY\n");
		}
	 }


//this function is used to check the ID if it existed or not
int ID_checker(int ID, student checkstud[stud_s]){
	int cntr, holder, cnt;
	cnt = count;
	if(ID == 0){
		return -1;
	}
		for(cntr = 0;  cntr <= cnt; cntr++){
			if(ID == checkstud[cntr].id){
				holder = cntr; 
				return holder;
			}
		}
		return -1;
}

//This code is used to validate the string input of the user, this will not allow number as inputs annd the special characters
int validate_string(char string[50]){
	char letter[41] = {"0123456789,./<>?;:\"\"\'\'\[]{}!@#$%^*()+_=`~"};
	
	int i, c, res = 0, m, result;
	
	string[0] = toupper(string[0]);// converts the 1st character to upper
	 for (m = 1; string[m] != '\0'; m++) {
     		   string[m] = tolower(string[m]);// converts the rest of the string to lower
   			 }
   			 result = strlen(string); // this will count the number of string inputted
		for (i = 0; i < result; i++){
	   			for(c= 0; c < 40; c++){
	   				if(string[i] == letter[c]){
	   				res = 1;
	   				goto here;

				   }else{
				   	   res = 0;
				   }
				}
   		 }
   		 here:
   		 if(res == 1){
   		 	printf("--NO NUMBERS OR EXTRA CHARACTERS\n");
			}
   		 return res;
}

//this function is used for validating the string input of the user
int validate_Input(char inputchar[length]){
	int res;
	res = strlen(inputchar);
	if(res > length-2){
		printf("Please Enter Characters (less than 30 )\n");
		return 0;
	}else if(res <= 2){
		printf("Please Enter Characters (greater than 2)\n");
		return 0;
		}
		return 1;
}                               

//this function is used for validating the number inputs of the user
void valid_INT_inpt(int validate){
		if(validate != 1){
		printf("(NOT A NUMBER. Please Input valid values)\n");
		getch();
	}
}

int gender_sort(student stud_Info[stud_s], char type_g[10], parent_Info parent[stud_s]){
	int i, cnt = 0, count;
	count = read_Info(stud_Info, parent);
	   printf("      --------------------------------------------------------------------------------------------------------------");
	   printf("\n      No. |     S.ID     |         Last Name        |        First Name       |        Middle Name       | Gender |\n ");
	   printf("     --------------------------------------------------------------------------------------------------------------\n");
	quickSortMain(stud_Info, parent, count); 
	for(i = 0; i < count; i++){
	if(strcmp(stud_Info[i].gender, type_g) == 0){
			cnt++;
			printf("        %-3d    %-10d          %-15s            %-15s           %-15s     %-7s  " , cnt, stud_Info[i].id, stud_Info[i].name_F.Lname, stud_Info[i].name_F.Fname, stud_Info[i].name_F.Mid_I, stud_Info[i].gender);
			printf("\n");	
		}	
	}
	return cnt;
}
	
	
int gender_count(student stud_Info[stud_s], char type_g[10]){
	int i, cnt = 0;
	
	for(i = 0; i < count; i++){
	if(strcmp(stud_Info[i].gender, type_g) == 0){
			cnt++;	
		}	
	}
	return cnt;
}

void quickSortMain(student stud_Info[stud_s], parent_Info parent[stud_s], int cnt){
  quickAscending(stud_Info, parent, 0, cnt-1);
}

//This is the sorting code whereas it uses quick sort type
void quickAscending(student stud_Info[stud_s], parent_Info parent[stud_s], int start, int end){
 	int pointer, res;
	student temp;
	student pivot;
	parent_Info holder;
	
	if(start < end){ 
		
    pointer = start;
    strcpy(pivot.name_F.Lname, stud_Info[end].name_F.Lname);
    strcpy(pivot.name_F.Fname, stud_Info[end].name_F.Fname);
    strcpy(pivot.name_F.Mid_I, stud_Info[end].name_F.Mid_I);
    int cnt;
    for(cnt = start; cnt < end; cnt++){
    
    	if(strcmp(stud_Info[cnt].name_F.Lname, pivot.name_F.Lname) < 0)  //Compares the elements with the pivot
        {
        	temp = stud_Info[cnt]; //Swapping happens
        	stud_Info[cnt] = stud_Info[pointer];
        	stud_Info[pointer] = temp;
        	
        	holder = parent[cnt]; //Swapping happens
        	parent[cnt] = parent[pointer];
        	parent[pointer] = holder;
       		pointer++; //Adavnces the pointer
        }else if(strcmp(stud_Info[cnt].name_F.Lname, pivot.name_F.Lname) == 0){	 //This will perform if and only if the Last name are the same                              
        	if(strcmp(stud_Info[cnt].name_F.Fname, pivot.name_F.Fname) < 0){
				temp = stud_Info[cnt]; //Swapping happens
	        	stud_Info[cnt] = stud_Info[pointer];
	        	stud_Info[pointer] = temp;
	        	
	        	holder = parent[cnt]; //Swapping happens
	        	parent[cnt] = parent[pointer];
	        	parent[pointer] = holder;
	       		pointer++; //Adavnces the pointer
			}else if(strcmp(stud_Info[cnt].name_F.Fname, pivot.name_F.Fname) == 0){ //This will perform if and only if the First name are the same
		   		if(strcmp(stud_Info[cnt].name_F.Mid_I, pivot.name_F.Mid_I) < 0){		
				temp = stud_Info[cnt]; //Swapping happens
	        	stud_Info[cnt] = stud_Info[pointer]; 
	        	stud_Info[pointer] = temp;
	        	
	        	holder = parent[cnt]; //Swapping happens
	        	parent[cnt] = parent[pointer];
	        	parent[pointer] = holder;
	       		pointer++; //Adavnces the pointer
       			}
			}
       }
}
    temp = stud_Info[end]; //Swapping happens when the count finishes comparing the array
    stud_Info[end] = stud_Info[pointer];
    stud_Info[pointer] = temp;
    
    holder = parent[end]; //Swapping happens
	parent[end] = parent[pointer];
	parent[pointer] = holder;
	 
    quickAscending(stud_Info, parent, start, pointer-1); //Compares the sub-arrays
    quickAscending(stud_Info, parent, pointer+1, end);
	}
}


void display_Info(student stud_class[stud_s], parent_Info parent_class[stud_s], int count){
	int ctr;
	
	   quickSortMain(stud_class, parent_class, count);
	   printf("      --------------------------------------------------------------------------------------------------------------");
	   printf("\n      No. |     S.ID     |         Last Name        |        First Name       |        Middle Name       | Gender |\n ");
	   printf("     --------------------------------------------------------------------------------------------------------------\n");
	   
		for(ctr = 0; ctr <  count; ctr++){
			printf("        %-3d    %-10d          %-15s            %-15s           %-15s     %-7s  " , ctr+1, stud_class[ctr].id, stud_class[ctr].name_F.Lname, stud_class[ctr].name_F.Fname, stud_class[ctr].name_F.Mid_I, stud_class[ctr].gender);
			printf("\n");
		}	
}

void display_Individual(student stud_Info[stud_s], parent_Info parent[stud_s], int val){
	   
	   printf("      --------------------------------------------------------------------------------------------------------------");
	   printf("\n      No. |     S.ID     |         Last Name        |        First Name       |        Middle Name       | Gender |\n ");
	   printf("     --------------------------------------------------------------------------------------------------------------\n");
	   
			printf("        1     %-10d          %-15s            %-15s           %-15s     %-7s  ", stud_Info[val].id, stud_Info[val].name_F.Lname, stud_Info[val].name_F.Fname, stud_Info[val].name_F.Mid_I, stud_Info[val].gender);
			printf("\n");
}

void disp_emgncy(parent_Info parent[stud_s], int val){
	
	   printf("      --------------------------------------------------------------------------------------------------------------");
	   printf("\n       No. |  Relationship  |   Last Name   |    First Name   |   Middle Name   | Contact Number |\n ");
	   printf("     --------------------------------------------------------------------------------------------------------------\n");

			printf("        1         %-10s     %-12s      %-12s     %-12s   %-11s  " , parent[val].relation, parent[val].P_name.Lname, parent[val].P_name.Fname, parent[val].P_name.Mid_I, parent[val].contact_num);
			printf("\n");

}

void display_Stud_Info(int val, student stud_Info[stud_s], parent_Info parent[stud_s]){
	printf("===============================================\n");
	printf("              Student Information\n");
	printf("===============================================\n");
	printf("Student ID                       %-7d\n", stud_Info[val].id);
	printf("-----------------------------------------------\n");
	printf("Student Name\n");
	printf("-------------\n");
	printf("Family Name                      %-15s\n", stud_Info[val].name_F.Lname);
	printf("First Name                       %-15s\n", stud_Info[val].name_F.Fname);
	printf("Middle Name                      %-15s\n", stud_Info[val].name_F.Mid_I);
	printf("-----------------------------------------------\n");
	printf("Address\n");
	printf("---------\n");
	printf("Barangay                         %-20s\n", stud_Info[val].address.barangay);
	printf("Town                             %-20s\n", stud_Info[val].address.town_City);
	printf("Province                         %-20s\n", stud_Info[val].address.province);
	printf("-----------------------------------------------\n");
	printf("Birthday\n");
	printf("---------\n");
	printf("Month                            %-12s\n", stud_Info[val].Birthday.Month);
	printf("Day                              %-2d\n", stud_Info[val].Birthday.day);
	printf("Year                             %-4d\n", stud_Info[val].Birthday.year);
	printf("-----------------------------------------------\n");
	printf("Contact Number                   %-11s\n", stud_Info[val].con_num);
	printf("-----------------------------------------------\n");
	printf("Gender                           %-7s\n", stud_Info[val].gender);
	printf("-----------------------------------------------\n");
	printf("               EMERGENCY INFORMATION\n");
	printf("-----------------------------------------------\n");
	printf("Relationship                     %-10s\n", parent[val].relation);
	printf("-----------------------------------------------\n");
	printf("%s Name\n", parent[val].relation);
	printf("-------------\n");
	printf("Family Name                      %-15s\n", parent[val].P_name.Lname);
	printf("First Name                       %-15s\n", parent[val].P_name.Fname);
	printf("Middle Name                      %-15s\n", parent[val].P_name.Mid_I);
	printf("-----------------------------------------------\n");
	printf("Address\n");
	printf("---------\n");
	printf("Barangay                         %-20s\n", parent[val].P_add.barangay);
	printf("Town                             %-20s\n", parent[val].P_add.town_City);
	printf("Province                         %-20s\n", parent[val].P_add.province);
	printf("-----------------------------------------------\n");
	printf("Contact Number                   %-11s\n", parent[val].contact_num);
	printf("----------------------------------------------------------\n");
	printf("Date of Enrollment               %-30s\n", stud_Info[val].enr_time);
	printf("----------------------------------------------------------\n");
	
}

void statistics(student stud_Info[stud_s], student unenrl_stud[stud_s], parent_Info parent[stud_s], parent_Info emgncy_Info[stud_s]){
	char male_type[10] = {"Male"}, female_type[10]={"Female"};
	int cnt, unerl_cnt, res_m, res_f;
	cnt = read_Info(stud_Info, parent);
	unerl_cnt = read_unrl(unenrl_stud, emgncy_Info);
	res_m = gender_count(stud_Info, male_type);
	res_f = gender_count(stud_Info, female_type);
	
	printf("STUDENTS ENROLLED: %d\n", cnt);
	printf("STUDENTS NOT ENROLLED: %d\n", unerl_cnt);                             
	printf("MALE: %d\n", res_m);
	printf("FEMALE: %d\n", res_f);
}
                         
//this function is used for writing a file of the student information
int writeStud_Info(student stud_Info[stud_s], parent_Info parent[stud_s]){
	int cntr;
	File = fopen("Enrolled Student Information.txt", "w"); //it will open the file
	if(File == NULL){
		return -1;
	}else{
		fprintf(File, "%d\n", count);
	for(cntr = 0; cntr < count; ++cntr){
		fputs(stud_Info[cntr].name_F.Lname, File);
		fprintf(File,"\n");
		
		fputs(stud_Info[cntr].name_F.Fname, File);
		fprintf(File,"\n");
		
		fputs(stud_Info[cntr].name_F.Mid_I, File);
		fprintf(File,"\n");
		
		fprintf(File, "%d\n", stud_Info[cntr].id);
		
		fputs(stud_Info[cntr].address.barangay, File);
		fprintf(File,"\n");
		
		fputs(stud_Info[cntr].address.town_City, File);
		fprintf(File,"\n");
		
		fputs(stud_Info[cntr].address.province, File);
		fprintf(File,"\n");
		
		fputs(stud_Info[cntr].Birthday.Month, File);
		fprintf(File,"\n");
		
		fprintf(File, "%d\n", stud_Info[cntr].Birthday.day);
		
		fprintf(File, "%d\n", stud_Info[cntr].Birthday.year);
		
		fputs(stud_Info[cntr].con_num, File);
		fprintf(File,"\n");
		
		fputs(stud_Info[cntr].gender, File);
		fprintf(File,"\n");
		
		fputs(parent[cntr].relation, File);
		fprintf(File,"\n");
		
		fputs(parent[cntr].P_name.Lname, File);
		fprintf(File,"\n");
		
		fputs(parent[cntr].P_name.Fname, File);
		fprintf(File,"\n");
		
		fputs(parent[cntr].P_name.Mid_I, File);
		fprintf(File,"\n");
		
		fputs(parent[cntr].contact_num, File);
		fprintf(File,"\n");
		
		fputs(parent[cntr].P_add.barangay, File);
		fprintf(File,"\n");
		
		fputs(parent[cntr].P_add.town_City, File);
		fprintf(File,"\n");
		
		fputs(parent[cntr].P_add.province, File);
		fprintf(File,"\n");
		
		fputs(stud_Info[cntr].enr_time, File);
		fprintf(File,"\n");
		}
	}
	fclose(File);// this will close the file
} 
 
//this function is used for reading the file of the student information
int read_Info(student stud_Info[stud_s], parent_Info parent[stud_s]){
	int cnt = 0, ctr = 0;
	File = fopen("Enrolled Student Information.txt", "r"); 
	if(File == NULL){
		return -1;
	}else{
	fscanf(File, "%d\n", &cnt);
	for(ctr = 0; ctr < cnt; ++ctr){
		fgets(stud_Info[ctr].name_F.Lname, length, File); 
		stud_Info[ctr].name_F.Lname[strlen(stud_Info[ctr].name_F.Lname) - 1] = 0;
		
		fgets(stud_Info[ctr].name_F.Fname, length, File);
		stud_Info[ctr].name_F.Fname[strlen(stud_Info[ctr].name_F.Fname) - 1] = 0;
		
		fgets(stud_Info[ctr].name_F.Mid_I, length, File);
		stud_Info[ctr].name_F.Mid_I[strlen(stud_Info[ctr].name_F.Mid_I) - 1] = 0;
		
		fscanf(File, "%d\n", &stud_Info[ctr].id);
	    
	    fgets(stud_Info[ctr].address.barangay, length, File);
	    stud_Info[ctr].address.barangay[strlen(stud_Info[ctr].address.barangay) - 1] = 0;
	    
	    fgets(stud_Info[ctr].address.town_City, length, File);
	    stud_Info[ctr].address.town_City[strlen(stud_Info[ctr].address.town_City) - 1] = 0;
	    
	    fgets(stud_Info[ctr].address.province, length, File);
	    stud_Info[ctr].address.province[strlen(stud_Info[ctr].address.province) - 1] = 0;
	    
	    fgets(stud_Info[ctr].Birthday.Month, 12, File);
	    stud_Info[ctr].Birthday.Month[strlen(stud_Info[ctr].Birthday.Month) - 1] = 0;
	    
	    fscanf(File, "%d\n", &stud_Info[ctr].Birthday.day);
	    
	    fscanf(File, "%d\n", &stud_Info[ctr].Birthday.year);
	    
	    fgets(stud_Info[ctr].con_num, 13, File);
	    stud_Info[ctr].con_num[strlen(stud_Info[ctr].con_num) - 1] = 0;
	    
	    fgets(stud_Info[ctr].gender, 8, File);
	    stud_Info[ctr].gender[strlen(stud_Info[ctr].gender) - 1] = 0;
	    
	    fgets(parent[ctr].relation, 15, File);
	    parent[ctr].relation[strlen(parent[ctr].relation) - 1] = 0;
	 	
	 	fgets(parent[ctr].P_name.Lname, length, File);
	    parent[ctr].P_name.Lname[strlen(parent[ctr].P_name.Lname) - 1] = 0;
		
		fgets(parent[ctr].P_name.Fname, length, File);
	    parent[ctr].P_name.Fname[strlen(parent[ctr].P_name.Fname) - 1] = 0;
	    
	    fgets(parent[ctr].P_name.Mid_I, length, File);
	    parent[ctr].P_name.Mid_I[strlen(parent[ctr].P_name.Mid_I) - 1] = 0;
	
		fgets(parent[ctr].contact_num, 15, File);
	    parent[ctr].contact_num[strlen(parent[ctr].contact_num) - 1] = 0; 
		
		fgets(parent[ctr].P_add.barangay, length, File);
	    parent[ctr].P_add.barangay[strlen(parent[ctr].P_add.barangay) - 1] = 0;
		
		fgets(parent[ctr].P_add.town_City, length, File);
	    parent[ctr].P_add.town_City[strlen(parent[ctr].P_add.town_City) - 1] = 0;
		
		fgets(parent[ctr].P_add.province, length, File);
	    parent[ctr].P_add.province[strlen(parent[ctr].P_add.province) - 1] = 0;
		
	    fgets(stud_Info[ctr].enr_time, 50, File);
	    stud_Info[ctr].enr_time[strlen(stud_Info[ctr].enr_time) - 1] = 0;

	}
	return cnt;
	}
	fclose(File);
}

int write_unenrl(student unenrl_stud[stud_s], parent_Info emgncy_Info[stud_s]){
	int cntr;
	unrl_F = fopen("Not Enrolled Student Information.txt", "w"); //it will open the file
	if(unrl_F == NULL){
		return -1;
	}else{
		fprintf(unrl_F, "%d\n", unrl_cnt);
	for(cntr = 0; cntr < unrl_cnt; ++cntr){
		fputs(unenrl_stud[cntr].name_F.Lname, unrl_F);
		fprintf(unrl_F,"\n");
		
		fputs(unenrl_stud[cntr].name_F.Fname, unrl_F);
		fprintf(unrl_F,"\n");
		
		fputs(unenrl_stud[cntr].name_F.Mid_I, unrl_F);
		fprintf(unrl_F,"\n");
		
		fprintf(unrl_F, "%d\n", unenrl_stud[cntr].id);
		
		fputs(unenrl_stud[cntr].address.barangay, unrl_F);
		fprintf(unrl_F,"\n");
		
		fputs(unenrl_stud[cntr].address.town_City, unrl_F);
		fprintf(unrl_F,"\n");
		
		fputs(unenrl_stud[cntr].address.province, unrl_F);
		fprintf(unrl_F,"\n");
		
		fputs(unenrl_stud[cntr].Birthday.Month, unrl_F);
		fprintf(unrl_F,"\n");
		
		fprintf(unrl_F, "%d\n", unenrl_stud[cntr].Birthday.day);
		
		fprintf(unrl_F, "%d\n", unenrl_stud[cntr].Birthday.year);
		
		fputs(unenrl_stud[cntr].con_num, unrl_F);
		fprintf(unrl_F,"\n");
		
		fputs(unenrl_stud[cntr].gender, unrl_F);
		fprintf(unrl_F,"\n");
		
		fputs(emgncy_Info[cntr].relation, unrl_F);
		fprintf(unrl_F,"\n");
		
		fputs(emgncy_Info[cntr].P_name.Lname, unrl_F);
		fprintf(unrl_F,"\n");
		
		fputs(emgncy_Info[cntr].P_name.Fname, unrl_F);
		fprintf(unrl_F,"\n");
		
		fputs(emgncy_Info[cntr].P_name.Mid_I, unrl_F);
		fprintf(unrl_F,"\n");
		
		fputs(emgncy_Info[cntr].contact_num, unrl_F);
		fprintf(unrl_F,"\n");
		
		fputs(emgncy_Info[cntr].P_add.barangay, unrl_F);
		fprintf(unrl_F,"\n");
		
		fputs(emgncy_Info[cntr].P_add.town_City, unrl_F);
		fprintf(unrl_F,"\n");
		
		fputs(emgncy_Info[cntr].P_add.province, unrl_F);
		fprintf(unrl_F,"\n");
		
		fputs(unenrl_stud[cntr].enr_time, unrl_F);
		fprintf(unrl_F,"\n");
		}
	}
	fclose(unrl_F);// this will close the file
} 

int read_unrl(student unenrl_stud[stud_s], parent_Info emgncy_Info[stud_s]){
	int cnt = 0, ctr = 0;
	unrl_F = fopen("Not Enrolled Student Information.txt", "r"); 
	if(unrl_F == NULL){
		return -1;
	}else{
	fscanf(unrl_F, "%d\n", &cnt);
	for(ctr = 0; ctr < cnt; ++ctr){
		fgets(unenrl_stud[ctr].name_F.Lname, length, unrl_F); 
		unenrl_stud[ctr].name_F.Lname[strlen(unenrl_stud[ctr].name_F.Lname) - 1] = 0;
		
		fgets(unenrl_stud[ctr].name_F.Fname, length, unrl_F);
		unenrl_stud[ctr].name_F.Fname[strlen(unenrl_stud[ctr].name_F.Fname) - 1] = 0;
		
		fgets(unenrl_stud[ctr].name_F.Mid_I, length, unrl_F);
		unenrl_stud[ctr].name_F.Mid_I[strlen(unenrl_stud[ctr].name_F.Mid_I) - 1] = 0;
		
		fscanf(unrl_F, "%d\n", &unenrl_stud[ctr].id);
	    
	    fgets(unenrl_stud[ctr].address.barangay, length, unrl_F);
	    unenrl_stud[ctr].address.barangay[strlen(unenrl_stud[ctr].address.barangay) - 1] = 0;
	    
	    fgets(unenrl_stud[ctr].address.town_City, length, unrl_F);
	    unenrl_stud[ctr].address.town_City[strlen(unenrl_stud[ctr].address.town_City) - 1] = 0;
	    
	    fgets(unenrl_stud[ctr].address.province, length, unrl_F);
	    unenrl_stud[ctr].address.province[strlen(unenrl_stud[ctr].address.province) - 1] = 0;
	    
	    fgets(unenrl_stud[ctr].Birthday.Month, 12, unrl_F);
	    unenrl_stud[ctr].Birthday.Month[strlen(unenrl_stud[ctr].Birthday.Month) - 1] = 0;
	    
	    fscanf(unrl_F, "%d\n", &unenrl_stud[ctr].Birthday.day);
	    
	    fscanf(unrl_F, "%d\n", &unenrl_stud[ctr].Birthday.year);
	    
	    fgets(unenrl_stud[ctr].con_num, 13, unrl_F);
	    unenrl_stud[ctr].con_num[strlen(unenrl_stud[ctr].con_num) - 1] = 0;
	    
	    fgets(unenrl_stud[ctr].gender, 8, unrl_F);
	    unenrl_stud[ctr].gender[strlen(unenrl_stud[ctr].gender) - 1] = 0;
	    
	    fgets(emgncy_Info[ctr].relation, 15, unrl_F);
	    emgncy_Info[ctr].relation[strlen(emgncy_Info[ctr].relation) - 1] = 0;
	 	
	 	fgets(emgncy_Info[ctr].P_name.Lname, length, unrl_F);
	    emgncy_Info[ctr].P_name.Lname[strlen(emgncy_Info[ctr].P_name.Lname) - 1] = 0;
		
		fgets(emgncy_Info[ctr].P_name.Fname, length, unrl_F);
	    emgncy_Info[ctr].P_name.Fname[strlen(emgncy_Info[ctr].P_name.Fname) - 1] = 0;
	    
	    fgets(emgncy_Info[ctr].P_name.Mid_I, length, unrl_F);
	    emgncy_Info[ctr].P_name.Mid_I[strlen(emgncy_Info[ctr].P_name.Mid_I) - 1] = 0;
	
		fgets(emgncy_Info[ctr].contact_num, 15, unrl_F);
	    emgncy_Info[ctr].contact_num[strlen(emgncy_Info[ctr].contact_num) - 1] = 0; 
		
		fgets(emgncy_Info[ctr].P_add.barangay, length, unrl_F);
	    emgncy_Info[ctr].P_add.barangay[strlen(emgncy_Info[ctr].P_add.barangay) - 1] = 0;
		
		fgets(emgncy_Info[ctr].P_add.town_City, length, unrl_F); 
	    emgncy_Info[ctr].P_add.town_City[strlen(emgncy_Info[ctr].P_add.town_City) - 1] = 0;
		
		fgets(emgncy_Info[ctr].P_add.province, length, unrl_F);
	    emgncy_Info[ctr].P_add.province[strlen(emgncy_Info[ctr].P_add.province) - 1] = 0;
	     
	    fgets(unenrl_stud[ctr].enr_time, 50, unrl_F);
	    unenrl_stud[ctr].enr_time[strlen(unenrl_stud[ctr].enr_time) - 1] = 0;

	}
	return cnt;
	}
	fclose(unrl_F);
}

void edit_Stud_Info(student stud_Info[stud_s], int result, parent_Info parent[stud_s]){
	 int validate = 0, choice = 0, ans;
	char first_name[15] = {"First Name"}, last_name[15] = {"Last Name"}, middle_name[15] = {"Middle Name"};
	

	 menu:
	 system("CLS");
	 display_Headpage();
	 writeStud_Info(stud_Info, parent);
	 display_Individual(stud_Info, parent, result);
	printf("\n\n==================");
	printf("\n      UPDATE\n");
	printf("==================\n");
	printf("1. Last Name \n");
	printf("2. First Name \n");
	printf("3. Middle Name\n");
	printf("4. Birthday \n");
	printf("5. Address \n");
	printf("6. Contact Number \n");
	printf("7. Gender \n");
	printf("8. Exit\n");
	choice=getche();
	choice=toupper(choice);
				switch(choice){
					case '1':
						printf("\nPROCEED[Y/N] >> ");
						ans=getche();
						ans=toupper(ans);
							switch(ans){
								case 'Y':
									printf("\n");
									name_Info(stud_Info[result].name_F.Lname, last_name);
									printf("\n\n\t\t\t\tRECORDS HAS BEEN UPDATED");
									getch();
									goto menu;
								case 'N':
									goto menu;
								default:
									printf("\nINVALID CHOICE\n");
									getch();
									goto menu;
							}
					case '2':
						printf("\nPROCEED[Y/N] >> ");
						ans=getche();
						ans=toupper(ans);
							switch(ans){
								case 'Y':
									printf("\n");
									name_Info(stud_Info[result].name_F.Fname, first_name);
									printf("\n\n\t\t\t\tRECORDS HAS BEEN UPDATED");
									getch();
									goto menu;
								case 'N':
									goto menu;
								default:
									printf("\nINVALID CHOICE\n");
									getch();
									goto menu;
							}
					
					case '3':
						printf("\nPROCEED[Y/N] >> ");
						ans=getche();
						ans=toupper(ans);
							switch(ans){
								case 'Y':
									printf("\n");
									name_Info(stud_Info[result].name_F.Mid_I, middle_name);
									printf("\n\n\t\t\t\tRECORDS HAS BEEN UPDATED");
									getch();
									goto menu;
								case 'N':
									goto menu;
								default:
									printf("\nINVALID CHOICE\n");
									getch();
									goto menu;
							}
					case '4':
						printf("\nPROCEED[Y/N] >> ");
						ans=getche();
						ans=toupper(ans);
							switch(ans){
								case 'Y':
											here:
											system("CLS");
											printf("Birthday: %s %d, %d\n", stud_Info[result].Birthday.Month, stud_Info[result].Birthday.day, stud_Info[result].Birthday.year);
											printf("Birthday\n");
											printf("[1] - Month\n");
											printf("[2] - Day\n");
											printf("[3] - Year\n");
											printf("[4] - Edit All\n");
											printf("[0] - Exit\n");
											ans=getche();
											ans=toupper(ans);
											switch(ans){
													case '1':
														printf("\n");
														month_Info(stud_Info, result);
														goto here;
													case '2':
														printf("\n");
														day_Info(stud_Info, result);
														goto here;
													case '3':
														printf("\n");
														year_Info(stud_Info, result);
														goto here;
													case '4':
														printf("\n");
														birth_Info(stud_Info, result);
														goto here;
													case '0':
														printf("\n\n\t\t\t\tRECORDS HAS BEEN UPDATED");
														getch();
														goto menu;
													default:
														printf("\n");
														printf("Invalid Choice\n");
														getch();
														goto here;
												}
											
										case 'N':
											goto menu;
										default:
											printf("\nINVALID CHOICE\n");
											getch();
											goto menu;
									}
						case '5':
							printf("\nPROCEED[Y/N] >> ");
							ans=getche();
							ans=toupper(ans);
							switch(ans){
								case 'Y':
									system("CLS");
									printf("Address: %s, %s, %s\n", stud_Info[result].address.barangay, stud_Info[result].address.town_City, stud_Info[result].address.province);
									address_Info(stud_Info[result].address.barangay, stud_Info[result].address.town_City, stud_Info[result].address.province);
									printf("Address: %s, %s, %s\n", stud_Info[result].address.barangay, stud_Info[result].address.town_City, stud_Info[result].address.province);
									printf("\n\n\t\t\t\tRECORDS HAS BEEN UPDATED");
									getch();
									goto menu;
								case 'N':
									goto menu;
								default:
									printf("\nINVALID CHOICE\n");
									getch();
									goto menu;
							}
						case '6':
							
							printf("\nPROCEED[Y/N] >> ");
							ans=getche();
							ans=toupper(ans);
							switch(ans){
								case 'Y':
									printf("\n");
									contact_num(stud_Info[result].con_num);
									printf("\n\n\t\t\t\tRECORDS HAS BEEN UPDATED");
									getch();
									goto menu;
								case 'N':
									goto menu;
								default:
									printf("\nINVALID CHOICE\n");
									getch();
									goto menu;
							}
							
						case '7':
							printf("\nPROCEED[Y/N] >> ");
							ans=getche();
							ans=toupper(ans);
							switch(ans){
								case 'Y':
									printf("\n");
									gender_Info(stud_Info, result);
									printf("\n\n\t\t\t\tRECORDS HAS BEEN UPDATED");
									getch();
									goto menu;
								case 'N':
									goto menu;
								default:
									printf("\nINVALID CHOICE\n");
									getch();
									goto menu;
							}
							
						case '8': 
							break;
						default:
							printf("\nInvalid Input. Please Try Again\n");
							getch(); 
							system("CLS");
							goto menu;
				}
}


void edit_emncy(student stud_Info[stud_s], int result, parent_Info parent[stud_s]){
	int choice, ans, validate;
	char first_name[15] = {"First Name"}, last_name[15] = {"Last Name"}, middle_name[15] = {"Middle Name"};

	 menu:
	 system("CLS");
	 writeStud_Info(stud_Info, parent);
	 display_Headpage();
	 disp_emgncy(parent, result);
	printf("\n\n========================");
	printf("\n   EMERGENCY INFORMATION\n");
	printf("========================\n");
	printf("1. Last Name \n");
	printf("2. First Name \n");
	printf("3. Middle Name\n");
	printf("4. Address \n");
	printf("5. Contact Number \n");
	printf("6. Relationship \n");
	printf("7. Exit\n");
	choice=getche();
	choice=toupper(choice);
				switch(choice){
					case '1':
							printf("\nPROCEED[Y/N] >> ");
							ans=getche();
							ans=toupper(ans);
							switch(ans){
								case 'Y':
									printf("\n");
									name_Info(parent[result].P_name.Lname, last_name);
									printf("\n\n\t\t\t\tRECORDS HAS BEEN UPDATED");
									getch();
									goto menu;
								case 'N':
									goto menu;
								default:
									printf("\nINVALID CHOICE\n");
									getch();
									goto menu;
							}
					case '2':
							printf("\nPROCEED[Y/N] >> ");
							ans=getche();
							ans=toupper(ans);
							switch(ans){
								case 'Y':
									printf("\n");
									name_Info(parent[result].P_name.Fname, first_name);
									printf("\n\n\t\t\t\tRECORDS HAS BEEN UPDATED");
									getch();
									goto menu;
								case 'N':
									goto menu;
								default:
									printf("\nINVALID CHOICE\n");
									getch();
									goto menu;
							}
					case '3':
							printf("\nPROCEED[Y/N] >> ");
							ans=getche();
							ans=toupper(ans);
							switch(ans){
								case 'Y':
									printf("\n");
									name_Info(parent[result].P_name.Mid_I, middle_name);
									printf("\n\n\t\t\t\tRECORDS HAS BEEN UPDATED");
									getch();
									goto menu;
								case 'N':
									goto menu;
								default:
									printf("\nINVALID CHOICE\n");
									getch();
									goto menu;
							}
					case '4':
							printf("\nPROCEED[Y/N] >> ");
							ans=getche();
							ans=toupper(ans);
							switch(ans){
								case 'Y':
									system("CLS");
									printf("Address: %s, %s, %s\n", parent[result].P_add.barangay, parent[result].P_add.town_City, parent[result].P_add.province);
									address_Info(parent[result].P_add.barangay, parent[result].P_add.town_City, parent[result].P_add.province);
									printf("Address: %s, %s, %s\n", parent[result].P_add.barangay, parent[result].P_add.town_City, parent[result].P_add.province);
									printf("\n\n\t\t\t\tRECORDS HAS BEEN UPDATED");
									getch();
									goto menu;
								case 'N':
									goto menu;
								default:
									printf("\nINVALID CHOICE\n");
									getch();
									goto menu;
							}
					case '5':
							printf("\nPROCEED[Y/N] >> ");
							ans=getche();
							ans=toupper(ans);
							switch(ans){
								case 'Y':
									printf("\n");
									contact_num(parent[result].contact_num);
									printf("\n\n\t\t\t\tRECORDS HAS BEEN UPDATED");
									getch();
									goto menu;
								case 'N':
									goto menu;
								default:
									printf("\nINVALID CHOICE\n");
									getch();
									goto menu;
							}
					case '6':
							printf("\nPROCEED[Y/N] >> ");
							ans=getche();
							ans=toupper(ans);
							switch(ans){
								case 'Y':
									printf("\n");
									relationship(parent, result);
									printf("\n\n\t\t\t\tRECORDS HAS BEEN UPDATED");
									getch();
									goto menu;
								case 'N':
									goto menu;
								default:
									printf("\nINVALID CHOICE\n");
									getch();
									goto menu;
							}
					case '7':
							break;
						default:
							printf("\nInvalid Input. Please Try Again\n");
							getch(); 
							system("CLS");
							goto menu;
				}
}
 

//this function is used for editing the inputs of the user
int edit_Info(student stud_Info[stud_s], student unenrl_stud[stud_s], parent_Info parent[stud_s], parent_Info emgncy_Info[stud_s]){

	int cnt, cnts, cntr, choice = 0, result, validate;
	int length1, length2, res = 0;
	char ID[10];
	int S_id;
	char ans;
	cnt = read_Info(stud_Info, parent);
		printf("*NOTE* - PROVIDE A STUDENT ID TO BE ABLE TO EDIT THE INFORMATION\n\n");
		printf("Enter Student ID >> ");
	    fflush(stdin);
		scanf("%d", &S_id);
		result = ID_checker(S_id, stud_Info);
		
		if(result == -1){
			printf("NO MATCHES FOUND\n");
			getch();
		}else {
			   
			      menu:
			      	system("CLS");
			      	display_Headpage();
					printf("-----------------------------------------------\n");
					printf("Student ID                       %-7d\n", stud_Info[result].id);
					printf("-----------------------------------------------\n");
					printf("Student Name : %s, %s, %s\n", stud_Info[result].name_F.Lname, stud_Info[result].name_F.Fname,  stud_Info[result].name_F.Mid_I);
					printf("-----------------------------------------------\n");
					printf("\n=======================\n");
					printf("    UPDATE INFORMATION\n");
					printf("\n=======================\n");
					printf("1.) Student Information\n");
					printf("2.) Emergency Information\n");
					printf("3.) Exit\n");
					choice=getche();
					choice=toupper(choice);
								switch(choice){
									case '1':
										system("CLS");
										edit_Stud_Info(stud_Info, result, parent);
										goto menu;
									case '2':
										system("CLS");
										display_Headpage();
										edit_emncy(stud_Info, result, parent);
										goto menu;
									case '3':
										break;
									default:
										printf("\nInvalid Input. Please Try Again\n");
										getch(); 
										system("CLS");
										goto menu;
								}
							}
				system("CLS");
}

int manual(){
    FILE* ptr;
    char str[10000];
    ptr = fopen("Manual.txt", "r");
    if (NULL == ptr) {
    	printf("PROGRAM TERMINATED\n");
        printf("Please Download the Manual.txt file to open the program\n");
        return 0;
    }
    system("CLS");
    while (fgets(str, 10000, ptr) != NULL) {
        printf("%s", str);
    }
    getch();
    return 1;
    fclose(ptr);
}

int Terms_conditions(){
    FILE* ptr;
    char str[10000];
    ptr = fopen("TermsConditions.txt", "r");
    if (NULL == ptr) {
    	printf("PROGRAM TERMINATED\n");
        printf("Please Download the Terms & Conditions.txt file to open the program\n");
        return 0;
    }
    system("CLS");
    while (fgets(str, 10000, ptr) != NULL) {
        printf("%s", str);
    }
    getch();
    return 1;
    fclose(ptr);
}

int monitor_terms(){
    FILE* ptr;
    char str[10000];
    ptr = fopen("TermsConditions.txt", "r");
    if (NULL == ptr) {
    	printf("\nPROGRAM TERMINATED\n");
        printf("Lack of resources, no Terms & Conditions\n");
        return 0;
    }
    return 1;
    fclose(ptr);
}

int monitor_manual(){
    FILE* ptr;
    char str[10000];
    ptr = fopen("Manual.txt", "r");
    if (NULL == ptr) {
    	printf("\nPROGRAM TERMINATED\n");
        printf("Lack of resources, no Manual\n");
        return 0;
    }
    return 1;
    fclose(ptr);
}

int main(){

	int validate = 0, choose = 0, choice = 0, res, ans, res_terms;
	int cnt = 0, cnt_f = 0, S_id, result, res_m, res_f;
	char male_type[10] = {"Male"}, female_type[10]={"Female"};
	student stud_Info[stud_s];
	student unenrl_stud[stud_s];
	parent_Info parent[stud_s];
	parent_Info emgncy_Info[stud_s];
	
	space();
	space();
	display_Headpage();
	getch();
	
	count = read_Info(stud_Info, parent);
	unrl_cnt = read_unrl(unenrl_stud, emgncy_Info);
	
	if(count == -1){
		res = manual();
		
		if(res == 0){
		exit(0);
		}
		res_terms = Terms_conditions();
		if(res_terms == 0) {
		exit(0);
		}
		count = 0;
		writeStud_Info(stud_Info, parent);
	}
	if(unrl_cnt <= 0){
		unrl_cnt = 0;
		write_unenrl(unenrl_stud, emgncy_Info);
	} 
	
	res = monitor_manual();
	res_terms = monitor_terms();
	if(res == 0) {
		exit(0);
	}else if(res_terms == 0){
		exit(0);
	}
	
	        
	menu: 
			system("CLS");
			read_Info(stud_Info, parent);
			read_unrl(unenrl_stud, emgncy_Info);
			display_Headpage();
			printf("MAIN MENU\n");
			printf("1. Enroll Student \n");
			printf("2. Modify Student \n");
			printf("3. Display Information\n");
			printf("4. Statistics\n");
			printf("5. Manual\n");
			printf("6. Terms & Conditions\n");
			printf("7. EXIT\n");
				choose=getche();
				choose=toupper(choose);
					switch(choose){
						case '1':
							system("CLS");
							display_Headpage();
							addStudent(stud_Info, unenrl_stud, parent);
							system("CLS");
							goto menu;
						
						case '2':
							modify:
							system("CLS");
							display_Headpage();
							printf("CHOOSE>> \n");
							printf("1. Update Student Information\n");
							printf("2. Enroll Existing Student\n");
							printf("3. Unenroll\n");
							printf("4. Exit\n");
							
							choice=getche();
							choice=toupper(choice);
								switch(choice){
									case '1':
										system("CLS");
										display_Headpage();
										if(count == 0){
										printf("\nUnable to open due to lack of data...\n");
										getch();
										goto modify;
										} 
										display_Info(stud_Info, parent, count);
										read_Info(stud_Info, parent);
										printf("\n\n\n");
										edit_Info(stud_Info, unenrl_stud, parent, emgncy_Info);
										goto modify;
										
									case '2':
										system("CLS");
										display_Headpage();
										if(unrl_cnt <= 0){
										printf("Unable to open due to lack of data...\n");
										getch();
										goto modify;
										}
										display_Info(unenrl_stud, emgncy_Info, unrl_cnt);
										read_unrl(unenrl_stud, emgncy_Info);
										printf("\n\n\n");
										add_exist_stud(stud_Info, unenrl_stud, parent, emgncy_Info);  
										getch();     
										goto modify;
									case '3':                                       
										if(count == 0){
												printf("\nUnable to open due to lack of data...\n");
												getch();
												goto modify;
											}
											
											proceed_c:
											printf("\n\nDO YOU WISH TO PROCEED[Y/N] >> ");
											ans=getche();
											ans=toupper(ans);
											switch(ans){
												case 'Y':
													system("CLS");
													display_Headpage();
													display_Info(stud_Info, parent, count);
													read_Info(stud_Info, parent);
													printf("\n\n\n");
													unenroll(stud_Info,unenrl_stud, parent, emgncy_Info);
													system("CLS");
													goto modify;
												case 'N':
													goto modify;
												default:
													printf("\nINVALID CHOICE. PLEASE TRY AGAIN\n");
													getch();
													goto modify;
											}
											
									case '4':
										goto menu;
									default:
											printf("\nINVALID INPUT\n");
											printf("PRESS ANY KEY TO CONTINUE...\n");
											getch();
											goto modify;
									}
					
						case '3':
							if(count == 0){
								printf("\nUnable to open due to lack of data...\n");
								getch();
								goto menu;
							} 
							display:
							system("CLS");
							display_Headpage();
							printf("1. List of Enrolled Students\n");
							printf("2. List of Male Students\n");
							printf("3. List of Female Student\n");
							printf("4. List of Not Enrolled Students\n");
							printf("5. Student Information\n");
							printf("6. Exit\n");
							
							choice=getche();
							choice=toupper(choice);
							
								switch(choice){
									case '1':
										system("CLS");
										display_Headpage();
										display_Info(stud_Info, parent, count);
										getch();
										goto display;
										
									case '2':
										
										res_m = gender_count(stud_Info, male_type);
										if(res_m == 0){
											printf("\nUnable to open due to lack of data...\n");
											getch();
											goto display;
										}else{
										system("CLS");
										display_Headpage();
										gender_sort(stud_Info, male_type, parent);
										getch();                              
										goto display;
										}
									case '3':   
										res_f = gender_count(stud_Info, female_type); 
										if(res_f == 0){
											printf("\nUnable to open due to lack of data...\n");
											getch();
											goto display;
										}else{                                   
										system("CLS");
										display_Headpage();
										gender_sort(stud_Info, female_type, parent);
										getch();
										goto display;
										}
									case '4':
										if(unrl_cnt == 0){
											printf("\nUnable to open due to lack of data...\n");
											getch();
											goto display;
										} 
										system("CLS");
										display_Headpage();
										display_Info(unenrl_stud, emgncy_Info, unrl_cnt);
										getch();          
										goto display;
									case '5':
										system("CLS");
										display_Headpage();
										display_Info(stud_Info, parent, count);
										printf("\n\nEnter Student ID >> ");
									    fflush(stdin);
										scanf("%d", &S_id);
										result = ID_checker(S_id, stud_Info);
										if(result == -1){
											printf("NO MATCH FOUND\n");
											getch();
											goto display;
										}
										system("CLS");
										display_Stud_Info(result, stud_Info, parent);
										getch();
										goto display;
									case '6':
										goto menu;
									default:
										printf("\nINVALID INPUT\n");
										printf("PRESS ANY KEY TO CONTINUE...\n");
										getch();
										goto display;
						}
						case '4':
							if(count == 0){
								printf("\nUnable to open due to lack of data...\n");
								getch();
								goto menu;
							} 
							system("CLS");
							display_Headpage();
							statistics(stud_Info, unenrl_stud, parent, emgncy_Info);
							getch();
							system("CLS");
							goto menu;
						
						case '5':
							system("CLS");
							manual();
							goto menu;
						case '6':
							system("CLS");
							Terms_conditions();
							goto menu;
						case '7':
							goto exit;
						default:
							printf("\nINVALID INPUT\n");
							printf("PRESS ANY KEY TO CONTINUE...\n");
							getch();
							goto menu;
				}
		exit:
	    system("CLS");
	    line_design();
	    space();
		name();
		space();
		line_design();
		getch();
		system("CLS");
	    space();                           
	    line_design();
	    toCenter();
    	printf("THANK YOU FOR USING THIS PROGRAM\n\n");
    	line_design();
    	space();
    	space();
    	text_boxDesign();
    	toCenter();
    	getch();
    	//THANK YOU LORD MANA NAJUD 2ND SEM NASAD HAHAHA
    	//#SURVIVE
}