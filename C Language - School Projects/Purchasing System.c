/*This program is password protected whereas you can make
or generate your password. This program comes up with two passwords which are for the Sales
Lady and the Head Inventory Associate, note that for each password you generate you need to
confirm it first before you proceed to the next step and each password has its purpose. The
allowed entry for the passwords should be less than the defined maximum size and greater than
the defined minimum size. If the password set up is done, another prompt will show which is for
inputting the password you generate for the Sales Lady and this will come up with validation of
your set up Sales Lady password to your entered password, note that you need to enter valid
and accepted entry which is less than the defined maximum size and greater than the defined
minimum size. You can now view the “Point of Sale and Inventory Management System” menu-
driven function if the password entered is correct but before that, you can see all the products
first. You are not allowed to enter invalid values, which are a letter and a number that is greater
or lesser than the choices. If the password is incorrect it will ask for your input over and over
again until it is matched.*/

#include<stdio.h>	
#include<string.h>
#define true 0 //true boolean
#define false 1 // for  false the boolean
#define size_max 20
#define size_min 3

void inventory_Main(); //declaration of function used in a part of the program 
//this struct is used for the sign up section
struct {
	char get_password[size_max];
	char inventories_pass[size_max];
}log_Info;

//this struct is used for point of sale system, used throughout the program
struct product_Info{
		char Id[10];   // product code/no.
		char name[size_max]; // product name
		int  quantity; // remaining quantity of product. Subtract from the original quantity the quantity purchased
        int  numSold;  // initially zero, when no purchase yet.
		float price;   // price of one piece of product
		int discount;  // discount for this product
		float sales;	// accumulated sales, total sales for this product
};
struct product_Info product[100]; //this is the maximum array of elements
int count = 0; //this assigns to global variable as this is used in every part of the program, this will be incremented if new products were entered
FILE *sale_file;
FILE *File;
//assigning a pointer file

//this function used to write all the signed up information and store to a file
void write_Sign_Up(){
	File = fopen("Login Information.txt", "w"); //it will open the file
	fputs(log_Info.get_password, File); //this will write the sales lady password to a file
	fprintf(File, "\n");
	fputs(log_Info.inventories_pass, File); //this will write the head inventory associates password to a file
	fclose(File);// this will close the file
	File = NULL;
}
//this function used to read the file only
int read_Sign_Up(){
	File = fopen("Login Information.txt", "r"); //this will open the file
	fgets(log_Info.get_password, size_max, File); //this will read the file for the sales  lady password
	log_Info.get_password[strlen(log_Info.get_password) - 1] = 0; // this will remove new lines in the files when reading
	fgets(log_Info.inventories_pass, size_max, File);	 // this will read the file for the head inventory associates password
	if(strlen(log_Info.get_password) > 0){//this will use to validate if there is any input in the file
		return 1; //returns 1 if the file is contained
	}else
		 return -1; //returns -1 if no written value or data in the file
	fclose(File);
	} //don't forget to close the file

//this function is used for the validation of string inputs by the user
void validate_Input(char inputchar[size_max]){
	if(strlen(inputchar) > size_max){
		printf("Please Enter Characters (less than 20 )");
	}else if(strlen(inputchar) <= size_min){
		printf("Please Enter Characters (greater than 3)");}}
		
//this function is used for the validation of integer inputs by the user
void valid_INT_inpt(int validate){
		if(validate != 1){
				printf("(NOT A NUMBER. Please Input valid values)\n");}}
				
//this function definition is for entering the password of the sales lady
void log_In_Section(){
	char password[size_max];
	read_Sign_Up(); //calling the function to read the file
	Enter_pass: //this function is used for loop back
	do{
		printf("\n\t\t\t\t\t============================================\n");
		printf("\t\t\t\t\t         ENTER SALES LADY PASSWORD\n");
		printf("\t\t\t\t\t============================================\n");	
		//the preceeding line is for the Password that use to validate its input
	do{
		printf("\n\t\t\t\t\t                 PassWord\n\t\t\t\t\t                 ");
		fflush(stdin);
		gets(password); //using gets to get the string input from the user
		fflush(stdin);
		validate_Input(password); // this line is calling the function to validate the string input from the user
	}while(strlen(password) > size_max || strlen(password) <= size_min);
			
		if(strcmp(password, log_Info.get_password) != 0 ){ //it is use to validate the input of the user if it match to the set up password
			printf("\t\t\t\t\t\t    INCORRECT PASSWORD\n");
		}else{
			fflush(stdin);
			goto correct_Pass;}	// this function is used to jump in the function wherever the password is correct
		getch(); //this will hang up the screen
		system("CLS"); //this will clear the screen
	}while(strcmp(password, log_Info.get_password) != 0);
	
	correct_Pass: // this is the destination if the password entered correctly
	printf("\t\t\t\t\t\t PASSWORD SUCCESSFULLY ENTERED");
	getch();
	fflush(stdin);
	fclose(File);}// this will close the file for the login information	

//this function definition is for the entry of the head inventory associate password
int head_pass(){
	char password[size_max];
	int counter;
	read_Sign_Up();//this call the function to read the file 

		printf("\n\t\t\t\t\t============================================\n");
		printf("\t\t\t\t\t   ENTER HEAD INVENTORY ASSOCIATE PASSWORD\n");
		printf("\t\t\t\t\t============================================\n");
		//the preceeding line is for the Password that use to validate its input
	do{
		printf("\n\t\t\t\t\t                 PassWord\n\t\t\t\t\t                 ");
		fflush(stdin);
		gets(password);
		fflush(stdin);
		validate_Input(password); // this line is used to validate the inputted string by the user
	}while(strlen(password) > size_max || strlen(password) <= size_min);
		//it is use to validate the input of the user if it match to the set up password		
		if(strcmp(password, log_Info.inventories_pass) != 0 ){
			printf("\t\t\t\t\t\t    INCORRECT PASSWORD\n");
			fflush(stdin);
			getch(); //this will freeze the screen
			system("CLS"); //this will clear the screen 
			return 1;
		}else{
			return 0;// this function is used to jump in the function wherever the password is correct
		}
			
	fclose(File); //this will close the file
	} 
	
// this section will be performed if the read function does not recognized a file or a file is empty
//this is also used to change the password of the sales lady
void sign_up_SalesLady(){
	char confirm_Pass[10];
	
		printf("\n\t\t\t\t\t============================================\n");
		printf("\t\t\t\t\t         SET UP SALES LADY PASSWORD\n");
		printf("\t\t\t\t\t============================================\n");
		
	//the preceeding line is for the Password that use to validate its input
	do{
		printf("\n\t\t\t\t\t                 PassWord\n\t\t\t\t\t                 ");
		fflush(stdin); //this will flush the standard input
		gets(log_Info.get_password); //using gets to get the input from the user
		fflush(stdin);
		validate_Input(log_Info.get_password); // calling the function to validate the input of the user
	}while(strlen(log_Info.get_password) > size_max || strlen(log_Info.get_password) <= size_min);
	
	//this lines is for the password confirmation
	do{
		printf("\n\t\t\t\t\t             Confirm PassWord\n\t\t\t\t\t                 ");
		fflush(stdin); //flush the output buffer of the stream
		gets(confirm_Pass); //this will the the password confirmation by the user
		fflush(stdin);
			if(strcmp(confirm_Pass, log_Info.get_password) != 0 ){ //this performs validation for the password confirmation
				printf("\t\t\t\t\t       INCORRECT PASSWORD VALIDATION\n");
				printf("\t\t\t\t\t     PLEASE CONFIRM THE PASSWORD AGAIN");}
	}while(strcmp(confirm_Pass, log_Info.get_password) != 0 );
	 write_Sign_Up();} //calling the function to write the data inputted by the user to the permanent data storage
	
// this section will be performed if the read function does not recognized a file or a file is empty
//this is also used to change the password of the Head Inventory Associate
void sign_up_HeadAssoc(){
	char confirm_Pass[size_max];
		printf("\n\t\t\t\t\t============================================\n");
		printf("\t\t\t\t\t    SET UP HEAD INVENTORY ASSOCIATE PASSWORD\n");
		printf("\t\t\t\t\t============================================\n");
	//this lines is used to get the input password from the user
	do{
		printf("\n\t\t\t\t\t                 PassWord\n\t\t\t\t\t                 ");
		fflush(stdin);
		gets(log_Info.inventories_pass); //this will get the password for the head inventory asssociate
		fflush(stdin);
		validate_Input(log_Info.inventories_pass); //calling the function to validate the inputted string by the user
	}while(strlen(log_Info.inventories_pass) > size_max || strlen(log_Info.inventories_pass) <= 5);
	//this lines is used for the password confirmation
	do{
		printf("\n\t\t\t\t\t             Confirm PassWord\n\t\t\t\t\t                 ");
		fflush(stdin);
		gets(confirm_Pass); //this will get the password confirmation from the user
		fflush(stdin);
			if(strcmp(confirm_Pass, log_Info.inventories_pass) != 0 ){ //this is the validation for the password confirmation
				printf("\t\t\t\t\t       INCORRECT PASSWORD VALIDATION\n");
				printf("\t\t\t\t\t     PLEASE CONFIRM THE PASSWORD AGAIN");}
	}while(strcmp(confirm_Pass, log_Info.inventories_pass) != 0 );
	write_Sign_Up();} //calling the function to write the data inputted by the user to the permanent data storage

//this function definition is for changing the password 
void change_pass(){
	int choice;
	char oldpass[size_max], oldpass_Head[size_max];
	
	main://this is the destination of the jump statement
	do{
	read_Sign_Up(); //this will read the file for the sign up
	printf("Select\n");
	printf("1. CHANGE SALES LADY PASSWORD\n");
	printf("2. CHANGE HEAD INVENTORY ASSOCIATE PASSWORD\n");
	printf("3. EXIT\n");
	
	printf("Choice >> ");
	fflush(stdin);
	scanf("%d", &choice); //getting the integer choice of the user
	fflush(stdin);
	if(choice > 3 || choice < 0){ //performs validation of the users input
		printf("Wrong Choice ");
		getch();//freeze the screen
		system("CLS");//clears the screen
	}else{//if the choice is valid this section will perform
	switch(choice){
		case 1:
			printf("Please Enter Old Password >> ");
			scanf("%s", oldpass); //getting the sales lady old password
			validate_Input(oldpass); //validating the input from the user which is the old password
			if(strcmp(oldpass, log_Info.get_password) != 0){//performs validation which is the inputted password of the user and true password of the user matched
				printf("\nIncorrect password");
				getch(); //freeze the screen
				system("CLS");// clear the screen
				goto main; //if the password entered is incorrect, this will directly jump to its destination
			}else{
				system("CLS");//clears the screen
				sign_up_SalesLady(); //calling the function sign up to enter new password
				printf("\n\n\n\t\t\t\t\t\t      RECORD UPDATED");
				getch();//freeze the screen
				system("CLS");//clears the screen
				goto main;// if the execution finished this will directly jump to its destination
			}
		case 2:
			printf("Please Enter Old Password >> ");
			scanf("%s", oldpass_Head);//getting the password for the head inventory associate
			validate_Input(oldpass_Head); // validating the input of the user for the errors
			if(strcmp(oldpass_Head, log_Info.inventories_pass) != 0){//validating the inputted password of the user if matched to the original password
				printf("\nIncorrect password");
				getch();//freeze the screen
				system("CLS");// clears the screen
				goto main;// if the execution finished this will directly jump to its destination
			}else{
				system("CLS");
				sign_up_HeadAssoc();//calling the funtion sign up to the head associate new password
				printf("\n\n\n\t\t\t\t\t\t      RECORD UPDATED");
				getch();//freeze the screen
				system("CLS");//clears the screen
				goto main;// if the execution finished this will directly jump to its destination
			}
		case 3:
			system("CLS");
			//this function is used to exit to the function
		}
		}}while(choice > 3 || choice < 0);
	write_Sign_Up();}

//this function is used to write the sales of the user inputted
int write_sales()//write file function
	{
    int A_count; //this variable is used as the counter of the for loop
    	sale_file = fopen("Sales Information System.txt", "w"); //do not append, not applicable
	    if (sale_file == NULL){
	        return -1;}	//if the file is not found it will return -1 value
   		fprintf(sale_file, "%d\n", count); //this will write the number of products entered by the user
    for (A_count = 0; A_count < count; ++A_count) // writing all the details from all the function to the text file.
    {
        fputs(product[A_count].Id, sale_file); //writing the Id input by the user to the file
        fprintf(sale_file, "\n");//this will create a newline to the file
        fputs(product[A_count].name, sale_file); //writing the name of the product inputted by the user to the file
        fprintf(sale_file, "\n");//this will create a newline to the file
        fprintf(sale_file, "%d\n", product[A_count].quantity);//writing the inputted value to the file
        fprintf(sale_file, "%d\n", product[A_count].numSold);//writing the inputted value to the file
        fprintf(sale_file, "%f\n", product[A_count].price);//writing the inputted value to the file
        fprintf(sale_file, "%d\n", product[A_count].discount);//writing the inputted value to the file
        fprintf(sale_file, "%f\n", product[A_count].sales);//writing the computed value to the file
    }
    fclose(sale_file);//this will close the file
    return 0;}// returns 0

//this function will read the sales  from the file
int read_sales() // read file function
{
    int cnt = 0; //this variable serves as the limit of the for loop
    int cntr; // this variable is used as the counter of the loop
   		 sale_file = fopen("Sales Information System.txt", "r");//this will open the file
    if (sale_file == NULL)
        return -1; 	//if the file is not found it will return -1 value
    fscanf(sale_file, "%d\n", &cnt); //this line is used to scan for the number of products written in the file
    for (cntr = 0; cntr < cnt; ++cntr)// reading all the details from the file
    {
        fgets(product[cntr].Id, 10, sale_file); // reading the Id written by the user from a file
        product[cntr].Id[strlen(product[cntr].Id) - 1] = 0; // remove new lines
        fgets(product[cntr].name, size_max, sale_file); // reading the name written by the user from a file
        product[cntr].name[strlen(product[cntr].name)-1] = 0; // remove new lines
        fscanf(sale_file, "%d", &product[cntr].quantity); // reading the value written in the file
        fscanf(sale_file, "%d", &product[cntr].numSold);// reading the value written in the file
        fscanf(sale_file, "%f", &product[cntr].price);// reading the value written in the file
        fscanf(sale_file, "%d", &product[cntr].discount);// reading the value written in the file
        fscanf(sale_file, "%f\n", &product[cntr].sales);// reading the computted value written in the file
    }
    fclose(sale_file);// this will close the file
    return cnt;} //returns the value of cnt
     
// for the switch number 6= calling all the product id with zero quantity.
void disZeroQuant(){ 
		int cntr;
        count= read_sales();	// call the read function
        printf("                                        ====================================\n");
  		printf("                                                    ZERO QUANTITY\n");
  		printf("                                        ====================================\n\n");
        for (cntr=0; cntr<count; cntr++){
		if(product[cntr].quantity == 0){// printing the highest product.
   		printf("\nName of the product: %s \nProduct Id: %s \nQuantity left: %d \nNumber of product sold: %d \nPrice of the product: %.2f \nDiscount of the product: %d %% \nTotal Sales: %.2lf\n\n",product[cntr].name, product[cntr].Id, product[cntr].quantity, product[cntr].numSold, product[cntr].price, product[cntr].discount, product[cntr].sales);
		}
     }
write_sales();		
}

// to display the highest sale function
void dispHsale(){ 
	int high, cntr;
	printf("                                        ====================================\n");
  	printf("                                                HIGHEST PRODUCT SALE\n");
  	printf("                                        ====================================\n\n");
	 high = product[0].numSold; // getting the first element of the array that has been sold
     for(cntr = 0;cntr < count; cntr++) // loop for the num item sold.
     {
          if(product[cntr].numSold > high)	//if the element containts the highest sold product.
          high = product[cntr].numSold;//it will pass on the high variable.
     }
   	for(cntr = 0;cntr < count; cntr++) // loop to search the highest sold product.
    {
	    if(product[cntr].numSold == high)// printing the highest product.
	    printf("Name of the product: %s \nProduct Id: %s \nQuantity left: %d \nNumber of product sold: %d \nPrice of the product: %.2f \nDiscount of the product: %d %% \nTotal Sales: %.2lf\n\n",product[cntr].name, product[cntr].Id, product[cntr].quantity, product[cntr].numSold, product[cntr].price, product[cntr].discount, product[cntr].sales);
	}}
	
// function for purchasing a product
void purchaseprod(){ 
	int quant, cntr, count, cnt, quan, validate = 0;
	float sales = 0, salesProd = 0, amount = 0, change = 0, validate_amount;
    char id[10];
    int z=false; 
    printf("                                        ===========================================\n");
    printf("                                                  ---PURCHASE A PRODUCT---\n");
    printf("                                        ===========================================\n");
    do{
    printf("\nQuantity of Items: ");
    fflush(stdin);
    validate = scanf("%d", &quan); 
    fflush(stdin);
    valid_INT_inpt(validate);
	}while(validate != 1);
    for(cnt = 0; cnt < quan; cnt++){
    count=read_sales(); //assigning read_sales function value return to count
    printf("===========================================");
	printf("\nSell an Item ");
    printf("\nProduct ID: ");
    fflush(stdin);
	gets(id);
    for (cntr=0; cntr<count; cntr++){
        if (strcmp(id,product[cntr].Id)==0) // if the id that the user want to find and the data id that has been saved at file is matched.
        {
        z=true;
        printf("\nItem found! Containing: \n");//...then display the match
	   	printf("Product name: %s",product[cntr].name);
		printf("\nPrice: %.2lfphp\n\n",product[cntr].price);
			do{
            printf("Enter the quantity you want to buy  : ");
            fflush(stdin);
			validate = scanf("%d",&quant);
			 fflush(stdin);
			valid_INT_inpt(validate);
			}while(validate != 1);
			
            if (quant>product[cntr].quantity){		// if the quantity is lessthan the users quant
               puts("\nInsufficient Quantity\nPlease Restock.\n ");
               getch();
             break; // break and back to the choices.
				}
           
            float tempSales = product[cntr].sales;  // will be executed if the quantity is greater than the users selected quantity.
            product[cntr].numSold += quant;
            product[cntr].quantity -= quant;
           	float discount = quant*product[cntr].price*(product[cntr].discount/100.0);
            product[cntr].sales = quant*product[cntr].price - discount;
            product[cntr].sales += tempSales;
			sales = quant * product[cntr].price;
			salesProd += sales;
			}
	}	
 if(z==false){	//if the product id is not available.
	printf("Cant find the product id: %s.\n",id);
	getch();
}
	write_sales();
	}
		printf("===========================================");
		printf("\nTOTAL = %.2f", salesProd);
		do{
		printf("\nPlease Enter Money Amount >> ");
		fflush(stdin);
		validate_amount = scanf("%f", &amount);
		fflush(stdin);
		if(validate_amount != 1){
			printf("\nNOT A NUMBER. PLEASE TRY AGAIN");
		}
		}while(validate_amount != 1);
		change = amount - salesProd;
		printf("\nCHANGE = %.2f", change);
		getch();
	} 
 
//function for the delete product.  
void deleteprod(){ 
	count=read_sales();
	char id[10]; 
	int cntr,cntr2;
	int z=false;
	printf("                                        ====================================\n");
  	printf("                                                   DELETE PRODUCT\n");
  	printf("                                        ====================================\n");
	printf("Enter the id that you want to be delete : "); //user's input for deleting.
	fflush(stdin);
	gets(id);//asking the user for its input which is the ID

	for(cntr=0;cntr<count;cntr++){		//loop to finding the user's input
		if(strcmp(id, product[cntr].Id)==0){ // if the user's input matched the data
		z=true; //z will become true
		for( cntr2=cntr; cntr2<(count-1); cntr2++)	// it will erase the selected data.
				{
					product[cntr2]=product[cntr2+1];
				}
				count--;
		}
	}
if(z==false){	// will be executed if the product id is not available.
	printf("Cant find product id: %s .",id);
}else{
	printf("\nPRODUCT DELETED SUCCESSFULLY");
}
write_sales();
}

// function to add products to the file 
void addProd(){
	int check, validate = 0;
	float f_valid = 0;
	get_ID: //destination of the jump function
	printf("                                        ====================================\n");
  	printf("                                                 ENTER NEW PRODUCTS\n");
  	printf("                                        ====================================\n");
	read_sales();//reading the files .
  	if (count > 0) {
  	    count = read_sales();
  	    
  	    printf("\nProduct ID Number: ");
		fflush(stdin); 
		gets(product[count].Id); //getting the users input for the ID
		if(strlen(product[count].Id) > 10){
			printf("Please enter characters less than 10");
			getch();
			system("CLS");
			goto get_ID;
		}else if(strlen(product[count].Id) <= size_min){
			printf("Please enter characters greater than 3");
			getch();
			system("CLS");
			goto get_ID;
		}
		
  		check = checkID(product[count].Id);	// to check if the id is already used.
			if(check == 1){//this will perform if the ID doesn't matched 
			 	goto step2;//this will jump to its destination if there is no ID exist
			}else{//this will perform if the ID matched
				printf("\nID IS ALREADY USED!!");
				getch();
				system("CLS");
				goto get_ID;}}//this will jump to its destination if the ID Exist
			
	else{//this will perform if there is no ID found in the file
		printf("\nProduct ID Number: ");
		fflush(stdin); 
		gets(product[count].Id);
		if(strlen(product[count].Id) > 10){
			printf("Please enter characters less than 10");
			getch();
			system("CLS");
			goto get_ID;
		}else if(strlen(product[count].Id) <= size_min){
			printf("Please enter characters greater than 3");
			getch();
			system("CLS");
			goto get_ID; 
		}
		}
		
	step2://this will be the destination if the ID doesn't exist
		do{
			printf("\nProduct Name: ");
			gets(product[count].name);
			validate_Input(product[count].name);//validate the input of the user which is to enter strings within limits only
		}while(strlen(product[count].name) > size_max || strlen(product[count].name) <= size_min);
		
		do{
			printf("Quantity of the product: ");
			fflush(stdin);
			validate = scanf("%d",&product[count].quantity);
			fflush(stdin);
			valid_INT_inpt(validate);//validate the input of the user which is to enter the numbers only
		}while(validate != 1);
		
		do{
			printf("Price of the product: ");
			fflush(stdin);
			f_valid = scanf("%f",&product[count].price);
			fflush(stdin);
			//validate the input of the user which is to enter the numbers only
			if(f_valid != 1){
				printf("NOT A NUMBER. Please input valid values\n");}
		}while(f_valid != 1);
		
		do{
			printf("Item Discount: ");
			fflush(stdin);
			validate = scanf("%d",&product[count].discount);
			fflush(stdin);
			valid_INT_inpt(validate);//validate the input of the user which is to enter the numbers only
		}while(validate != 1);
		++count; // increment count for the product positions and how many are they in the array.
		fflush(stdin);
		write_sales(); // putting/saving this to the file.
}

// checking the id if available
int checkID(char id[10]){ 
	int i;
	count=read_sales();
	read_sales();
 	for(i=0;i<count;i++){	 
			if(strcmp(id,product[i].Id)==0){ //if the id and data id  match.
			fclose(sale_file);
			return 0;	// returning 0 if id and data id matched
		}
 	 }		
 	fclose(sale_file);
 	return 1; // return 1 if id and data id doesn't match
} 

//Editing the product function
void editProd(){
char id[10];
int test, cntr, choice, validate = 0;
float f_valid = 0;

  	printf("                                        ====================================\n");
  	printf("                                                   EDIT A PRODUCT\n");
  	printf("                                        ====================================\n");
  printf("\nEnter the id of the product that you want to edit: "); // users input for what data will be change
	fflush(stdin);
	gets(id);
 		read_sales();//read the file
  {
	for(cntr=0;cntr<count;cntr++){
  	if(strcmp(id,product[cntr].Id)!=0) // if the data is not empty 
		write_sales();
   else
	   {
	    printf("\n1. Update product ID Number?");
	    printf("\n2. Update Name of the product? ");
	    printf("\n3. Update Quantity of the product?");
	    printf("\n4. Update Price of the product?");
	    printf("\n5. Update Discount of the product?");
	    printf("\n6. EXIT");
	    do{
	    printf("\nEnter your choice:");
	    fflush(stdin);
	    scanf("%d", &choice);
			if(choice > 6 || choice < 1){
				printf("Invalid Selection");
			}else{
			    switch (choice)
			    {/*the statements below will be performed if the choice is valid and each case will perform according to its choice,
				each case has a validation except for the ID which is not applicable for validation as ID can be edited in the edit function and
				it is not advisable to edit the ID,edit only if needed*/
			    case 1:
			     	 printf("Enter new ID: ");
			 	     fflush(stdin);
			         gets(product[cntr].Id);
			         fflush(stdin);
			    	 break;
			    case 2:
				    do{
				     printf("Enter new Name: ");
				    	fflush(stdin);
				         gets(product[cntr].name);
				         validate_Input(product[cntr].name);
				    }while(strlen(product[cntr].name) > size_max || strlen(product[cntr].name) <= size_min);
				     break;
			    case 3:
			    	do{
			    	 printf("Enter Quantity: ");
			    	 fflush(stdin);
			      	 validate = scanf("%d",&product[cntr].quantity);
			      	 fflush(stdin);
			      	 valid_INT_inpt(validate);
					}while(validate != 1);
			   		 break;
			    case 4:
			    	do{
			    	 printf("Enter the new price: ");
			    	 fflush(stdin);
			      	 f_valid = scanf("%f",&product[cntr].price);
			      	 fflush(stdin);
			      	 if(f_valid != 1){
			      	 	printf("NOT A NUMBER. Please input valid values\n");
					   }
			      	 }while(f_valid != 1);
			    	 break;
			     case 5:
			     	do{
			     	 printf("Enter the new discount of the product: ");
			     	 fflush(stdin);
			  		 validate = scanf("%d",&product[cntr].discount);
			  		 fflush(stdin);
			  		 valid_INT_inpt(validate);
			  		}while(validate != 1);
			  		break;
				case 6:
					system("CLS");
					inventory_Main();
				}
				 }
		}while(choice > 6 || choice < 1);
   write_sales();
   printf("RECORD UPDATED");
   goto closefile;//this will jump to the destination
		}		 } 
  }
  printf("The id num %s is not found.", id);//performed if the id cannot be found
  closefile://this is the destination 
  fclose(sale_file);}//closes the file
  
//This function is for resetting the product sold
void reset_Prodsold(){
	int counter;
	read_sales(); // reading the file for sales
	for(counter = 0; counter <  count; counter++){//this perform the following
		product[counter].numSold = 0; //setting the number of sold to zero
		printf("\nSerial Number %d Reset to 0", counter+1);
	}
	printf("\nAll Products Sold is now Zero");
	write_sales(); // writing the details to the file
	getch();
}
//this function is for resetting the sales
void reset_Sales(){
	int counter;
	read_sales();// reading the file for sales
	for(counter = 0; counter <  count; counter++){
		product[counter].sales = 0; //setting the sales to zero
		printf("\nSerial Number %d Reset to 0", counter+1);
	}
	printf("\nAll Products Sales is now Zero");
	write_sales(); // writing all the details to the file
	getch();
}
//this function is for setting the quantity for the whole
void edit_Quantityprod(){
	int counter, quantity, validate;
	read_sales();
	do{
	printf("How many quantity of products you want for whole >> ");
	fflush(stdin);
	validate = scanf("%d", &quantity);
	fflush(stdin);
	valid_INT_inpt(validate);// validate the users input
	}while(validate != 1);
	for(counter = 0; counter <  count; counter++){
		product[counter].quantity = quantity; // setting the quantity to the users inputted quantity
		printf("\nSerial Number %d is set to %d", counter+1, quantity);
	}
	printf("\nAll Products Sales is now set to the quantity of %d", quantity);
	write_sales();// write all the data into a file
	getch();
}
//this function will display the product
void displayprod(){
	int cntr;
  count = read_sales(); // the output is how many products inside the file.
  if (count < 0)
    puts("cannot open file");//this will perform if no file is found
	printf(" \t\t\t\t                   *****  PRODUCTS *****\n");
   printf("          -------------------------------------------------------------------------------------------------------\n");
   printf("            S.N.|         NAME           |   PROD ID  |  QUANTITY | PROD SOLD |  PRICE  |   DISCOUNT   |  SALES  \n");
   printf("          -------------------------------------------------------------------------------------------------------\n");

   for (cntr=0;cntr<count;cntr++){ // getting the details on each product updates.
   printf("           %-3d     %-20s        %-8s     %-5d      %-3d        %-6.2f      %-5d%%      P%.2lf\n",cntr+1, product[cntr].name, product[cntr].Id, product[cntr].quantity, product[cntr].numSold, product[cntr].price, product[cntr].discount, product[cntr].sales);
   printf("          -------------------------------------------------------------------------------------------------------\n");
	}
}
//this function is for the menu driven, which is for the password protected product inventory
void inventory_Main(){
	int choice, value = 0;
	count = read_sales(); // ihapa una pila imong products
	if(count < 0) // there is no file located.
		printf("NO FILE FOUND\n");
	mainSALE: //destination 
	do{
	printf("\n");
	printf("\t\t\t\t\t  ================================\n");
	printf("\t\t\t\t\t     INVENTORY MANAGEMENT SYSTEM\n");
	printf("\t\t\t\t\t  ================================");

	printf("\n\nPress:");
	printf("\n 1.) Input new product record");
	printf("\n 2.) Edit a Product");
	printf("\n 3.) Delete a Product");
	printf("\n 4.) Display all existing product");
	printf("\n 5.) Display the product record with highest sale");
	printf("\n 6.) Display all product with zero quantity");
	printf("\n 7.) RESET NUMBER OF PRODUCTS SOLD");
	printf("\n 8.) RESET SALES");
	printf("\n 9.) EDIT ALL QUANTITY OF PRODUCTS");
	printf("\n 10.) Exit");

	printf("\nChoice--> ");
	fflush(stdin);
	scanf("%d", &choice);
	fflush(stdin);
	if(choice > 10 || choice < 1){
		printf("Your choice is wrong please try again");
	}
	     switch(choice){//this will perform if the choice is valid
        case 1 :  //add product
        		system("CLS");//clear the screen
                addProd(); //calling the function to add product
                system("CLS");//clear the screen
                goto mainSALE;//this will jump to its destination
        case 2://edit data product
        		system("CLS");//clear the screen
		    	editProd();//calling the function to edit product
		    	getch();//freeze the screen
		    	system("CLS");//clear the screen
		    	goto mainSALE;//this will jump to its destination
        case 3://delete a product
		        system("CLS");//clear the screen
		        deleteprod();//calling the function to delete product
		        getch();//freeze the screen
		        system("CLS");//clear the screen
		        goto mainSALE;//this will jump to its destination
        case 4: //display the products
        		system("CLS");//clear the screen
                displayprod();//calling the function to display product
                getch();//freeze the screen
                system("CLS");//clear the screen
                goto mainSALE;//this will jump to its destination

	   	case  5:
		   		system("CLS");//clear the screen
		   		dispHsale(); // to display highest sale.
		   		getch();//freeze the screen
		   		system("CLS");//clear the screen
		   		goto mainSALE;//this will jump to its destination
		case 6:
				system("CLS");//clear the screen
				disZeroQuant(); // display lowest sale.
				getch();//freeze the screen
				system("CLS");//clear the screen
				goto mainSALE;//this will jump to its destination
		case 7:
				system("CLS");
				printf("\n\n\n\n\n\n\t *NOTE*: THIS IS VERY RESTRICTED PART(NEED TO ACCESS WITH HEAD INVENTORY PASSWORD and SALES LADY PASSWORD)");
				printf("\n\t\t\t\t     If mistakenly pressed, just enter incorrect password");
				getch();
				system("CLS");
				printf("\n\t\t\t\t\t============================================\n");
				printf("\t\t\t\t\t   THIS PASSWORD ENTRY IS FOR RESET SOLD\n");
				printf("\t\t\t\t\t============================================");
				printf("\n\t\t\t\t     If mistakenly pressed, just enter incorrect password");
				value = head_pass();
				if(value == 0){
				log_In_Section();
				system("CLS");//clear the screensystem("CLS");//clear the screen
				reset_Prodsold();
				}
				system("CLS");
				goto mainSALE;//this will jump to its destination
		case 8: 
				system("CLS");
				printf("\n\n\n\n\n\n\t *NOTE*: THIS IS VERY RESTRICTED PART(NEED TO ACCESS WITH HEAD INVENTORY PASSWORD and SALES LADY PASSWORD)");
				printf("\n\t\t\t\t     If mistakenly pressed, just enter incorrect password");
				getch();
				system("CLS");
				printf("\n\t\t\t\t\t============================================\n");
				printf("\t\t\t\t\t   THIS PASSWORD ENTRY IS FOR RESET SALES\n");
				printf("\t\t\t\t\t============================================");
				printf("\n\t\t\t\t     If mistakenly pressed, just enter incorrect password");
				value = head_pass();
				if(value == 0){
				log_In_Section();
				system("CLS");//clear the screensystem("CLS");//clear the screen
				reset_Sales();
				}
				system("CLS");
				goto mainSALE;//this will jump to its destination
		case 9:
				system("CLS");
				printf("\n\n\n\n\n\n\t *NOTE*: THIS IS VERY RESTRICTED PART(NEED TO ACCESS WITH HEAD INVENTORY PASSWORD and SALES LADY PASSWORD)");
				printf("\n\t\t\t\t     If mistakenly pressed, just enter incorrect password");
				getch();
				system("CLS");
				printf("\n\t\t\t\t\t============================================\n");
				printf("\t\t\t\t\t  THIS PASSWORD ENTRY IS FOR RESET QUANTITY\n");
				printf("\t\t\t\t\t============================================");
				printf("\n\t\t\t\t     If mistakenly pressed, just enter incorrect password");
				value = head_pass();
				if(value == 0){
				log_In_Section();
				system("CLS");//clear the screensystem("CLS");//clear the screen
				edit_Quantityprod();
				}
				system("CLS");
				goto mainSALE;//this will jump to its destination
		case 10:
			printf("PRESS ANY KEY...");
			   break;
      }
      getch();
      system("CLS");
  }while(choice > 10 || choice < 1); // infinite loop until the user will choose invalid number.
}
//this function is for the Point of Sale System in which this section can make purchase and can also oversee products
int main_POS(){
	system("CLS");
	int choice, value, validate;
	main:
	do{
	printf("\t\t\t\t\t---------------------------------------------------\n");
	printf("\t\t\t\t\t   POINT OF SALE AND INVENTORY MANAGEMENT SYSTEM\n");
	printf("\t\t\t\t\t---------------------------------------------------\n");
	printf("SELECT\n");
	printf("1. MAKE PURCHASE\n");
	printf("2. DISPLAY PRODUCTS\n");
	printf("3. IMS(INVENTORY MANAGEMENT SYSTEM)\n");
	printf("4. CHANGE PASSWORD\n");
	printf("5. EXIT\n");
	
	printf("Choice >> ");
	fflush(stdin);
	validate = scanf("%d", &choice);
	fflush(stdin);
	if(choice > 5 || choice < 1){
		printf("INVALID CHOICE\n");
		if(validate != 1){
			printf("NOT A NUMBER.Please Try Again\n");
		}
	}else{
		switch(choice){
			case 1:
				system("CLS");
				purchaseprod();
				system("CLS");
				goto main;
			case 2:
				system("CLS");
				displayprod();
				getch();
				system("CLS");
				goto main;
			case 3:
				system("CLS");
				printf("\n\n\n\n\n\n\t\t  *NOTE*: This is password protected(NEED TO ACCESS WITH HEAD INVENTORY PASSWORD)");
				getch();
				system("CLS");
				value = head_pass();
				if(value == 0){
					system("CLS");
					inventory_Main();
				}
				system("CLS");
				goto main;
			case 4:
				system("CLS");
				change_pass();
				goto main;
			case 5: 
				system("CLS"); 
				printf("\n\n\n\n\n\n");
				printf("                                   =====================================================\n");
				printf("                                                  HOLY NAME UNIVERSITY\n");
				printf("                                               COLLEGE OF COMPUTER STUDIES\n");
				printf("                                       BACHELOR OF SCIENCE IN INFORMATION TECHNOLOGY\n");
				printf("                                            THANK YOU FOR USING THE APPLICATION\n");
				printf("                                              FINAL PROJECT 2ND SEMESTER 2022\n");
				printf("                                                   BIANCENT PACATANG\n");
				printf("                                   =====================================================\n");
				getch();
				return 0;
				break;
		}
	}
	getch();
	system("CLS");
	}while(choice > 5 || choice < 1 && validate != 1);
}
//this is the main function
main(){
	int choice;
	int account;
	printf("\n\n\n\n\n\n\n\n\n\n\n");
	printf("                           ==============================================================\n");
	printf("                                         *****WELCOME TO PURCHASING SYSTEM*****");
	printf("\n                           ==============================================================\n");
	printf("\n\n\n\n\n\n\n\n\n\n");
	printf("                                                 HOLY NAME UNIVERSITY\n");
	printf("                                              COLLEGE OF COMPUTER STUDIES\n");
	printf("                                      BACHELOR OF SCIENCE IN INFORMATION TECHNOLOGY\n");
	printf("                                                FINAL PROJECT 2ND SEM\n");
	printf("                                                      CCS 103");
	getch();
	system("CLS");
	account = read_Sign_Up();
	if(account < 0){ // this will perform if no data is found in the file
		sign_up_SalesLady();// calling the sign up function for the sales lady
		system("CLS");
		sign_up_HeadAssoc();// calling the sign up function for the head associate
		system("CLS");
		log_In_Section();// calling the function for the log in section for sales lady
		system("CLS");
		displayprod();//  calling the function to display the products
		printf("PLEASE PRESS ANY KEY TO CONTINUE...");
		getch();
		system("CLS");
		main_POS();// calling the function for the main Point of Sale System
	}else{// this will perform if the file contains passwords or data
		log_In_Section();// calling the function for the log in section
		system("CLS");
		fflush(stdin);
		displayprod();// calling the function for displaying all the products
		printf("PLEASE PRESS ANY KEY TO CONTINUE...");
		getch();
		system("CLS");
		main_POS();//  calling the function for the main POint of SalE System
	}
}
