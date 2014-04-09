/*
 * Name: Michael Neary
 * File: hw3.c
 * Date: April 3rd, 2014
 * CMSC 313 - Dr. Sadeghian
 * Description:
 *
 * This program calculates pi based on a user-entered odd number.
 * Then, it either displays the calculation on the screen or writes it to
 * a file.
 * 
 */

//preprocessor directives
#include <stdio.h>
#include <string.h>

//macros
#define WRITE_FILE 1
#define WRITE_SCREEN 2

//method stubs
float calcPi(int oddNum);
void printToScreen(int oddNum, float pi);
void writeToFile(char f_name[], int oddNum, float pi);

int main(){

  //variable declarations
  int user_num;
  int user_choice;
  float pi;
  char file_name[10];

  //get user input
  //keep asking until the input is both odd and positive
  printf("Enter a positive odd integer: ");
  scanf("%d",&user_num);

  while(1){
    if(user_num > 0 && (user_num % 2 != 0)){
      break;
    }
    else{
      printf("\nEnter a positive odd integer: ");
      scanf("%d",&user_num);
    }
  }

  //calculate pi based on the entered odd number
  pi = calcPi(user_num);

  //ask user to if they want to write to file                                                              
  //or if they want to write to console
  printf("\n\nEnter 1 to write to a file\n");
  printf("\nEnter 2 to write to the screen: ");
  scanf("%d",&user_choice);
  
  while(1){

    //one switch statement required
    switch(user_choice){

    case WRITE_FILE:
      printf("\nEnter the name of a file (9 char or less): ");
      scanf("%s",file_name);
      writeToFile(file_name, user_num, pi);
      break;

    case WRITE_SCREEN:
      printToScreen(user_num, pi);     
      break;
    
    default:
      //if not 1 or 2 user choice not valid
      printf("\nYou did not enter 1 or 2.\n");
      break;
      
    }

    if(user_choice == 1 || user_choice == 2){
      break;
    }
    else{
      //ask again
      printf("\n\nEnter 1 to write to a file\n");
      printf("\nEnter 2 to write to the screen: ");
      scanf("%d",&user_choice);
    }
  }
  return 0;
}

/*
 * Function: calcPi
 * Parameters: oddNum - user entered integer that is both positive and odd
 * Returns: floating point approximation of pi
 * Side effects: none
 */
float calcPi(int oddNum){
  
  float offset = 0;
  int i = 1;
  int j = 1;

  //The even parts of the sequence of odd numbers 
  //leading to the entered one is subtracted from the offset
  //the odd parts of the sequence of odd numbers 
  //leading to the enterd one is added to the offset
  while(i <= oddNum){
    if(j % 2 == 0){
      offset -= (1.0 / i);
    }
    else{
      offset += (1.0 / i);
    }
    i += 2;
    j += 1;
  }
  //return the calculated value of pi
  return 4 * offset;
}

/*
 * Function: printToScreen
 * Parameters: oddNum - user entered positive odd number
 *             pi - the calculated value of pi
 * Returns: nothing
 * Side effects: prints how the calculation was made to the screen
 */
void printToScreen(int oddNum, float pi){

  printf("\nOK, I will calculate ...\n\n");
  printf("4 X ( ");
  int i = 1;
  int j = 1;

  //instead of actually calulating the value of pi,
  //print where you would add or subtract to the offset
  while(i <= oddNum){
    
    if(i == 1){
      printf("1 ");
    }
    else if(j % 2 == 0){      
      printf("- 1/%d ",i);
    }
    else{
      printf("+ 1/%d ",i); 
    }
    
    if( j % 5 == 0 && i != oddNum){
      printf("\n\n        ");
    }

    i += 2;
    j += 1;
  }  
  printf(")\n\n...which is equal to %f\n",pi);
}

/*
 * Function: writeToFile
 * Parameters: f_name[] - string that is at most 9 characters long, contains file name
 *             oddNum - positive odd integer the user entered
 *             pi - floating point calculated value of pi
 * Returns: nothing
 * side effects: writes how the pi approximation was calculated to the file name given
 */
void writeToFile(char f_name[], int oddNum,float pi){
  
  FILE *file;
  /* try to open file to write, output error if unsuccessful*/
  file = fopen(f_name,"w");
  if (file == NULL){
    printf("Error opening file\n");
    return;
  }

  fprintf(file,"OK, I will calculate ...\n\n");
  fprintf(file,"4 X ( ");
  int i = 1;
  int j = 1;

  //instead of actually caculating the offset
  //write to file where you would add or subtract 
  while(i <= oddNum){
    if(i == 1){
      fprintf(file,"1 ");
    }
    else if(j % 2 == 0){
      
      fprintf(file,"- 1/%d ",i);
    }
    else{
      fprintf(file,"+ 1/%d ",i); 
    }
    
    if( j % 5 == 0 && i != oddNum){
      fprintf(file,"\n\n        ");
    }
    i += 2;
    j += 1;
  }
  
  fprintf(file,")\n\n...which is equal to %f\n",pi);
  fclose(file);
}
