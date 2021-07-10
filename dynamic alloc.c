
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void dynamic_alloc(int N);
void insert_student_dynamic();

struct DateOf_Birth {
   int year;
   int month;
   int day;
};

typedef struct student{
   char Name[50];
   int ID;
   struct DateOf_Birth dateof_birth;
   int Score;
}Student;

struct student *students;
int n;

int main()
{   int choice;
    printf("\t\t\t\t\t--------------WELCOME!--------------\nEnter number of students:");
    scanf("%d",&n);
    dynamic_alloc(n);
       
    return 0;
}


void dynamic_alloc(int n){

     students=(struct student*)(malloc(n*sizeof(struct student)));
     for(int i=0;i<n;i++){ //Getting the data of students

         printf("Enter name of student %d:",i+1);
         scanf("%s",&(students + i)->Name) ;
         printf("Enter ID of student %d:",i+1);
         scanf("%d",&(students + i)->ID) ;
         printf("Enter day of birth of student %d:",i+1);
         scanf("%d",&(students + i)->dateof_birth.day) ;
         printf("Enter month of birth of student %d:",i+1);
         scanf("%d",&(students + i)->dateof_birth.month) ;
         printf("Enter year of birth of student %d:",i+1);
         scanf("%d",&(students + i)->dateof_birth.year) ;
         printf("Enter score of student %d:",i+1);
         scanf("%d",&(students + i)->Score);
     }
     printf("\nTotal Size of this Data Structure is %d", n*sizeof(students)); //calculating size taken by structure
     clock_t t; //Identifying a variable to store time elapsed in it
    int choice;
    while(choice!=4){
    printf("\n1-Insert From beginning\n2-Insert From middle\n3-Insert From end\n4-Terminate\n\nEnter your choice:");
    scanf("%d",&choice);
    switch (choice)
    {
        case 1:{
            struct student *temp_student;
             students=(struct student*)realloc(students, (n + 1) * sizeof(struct student));//Increasing the size of array by reallocation
             temp_student=(struct student*)(malloc(sizeof(struct student))); //its an empty slot to store the data of new student
             n++;
             //getting the data of the new student & storing it in the empty slot
             printf("Enter name of student:");
             scanf("%s",&(temp_student)->Name) ;
             printf("Enter ID of student:");
             scanf("%d",&(temp_student)->ID) ;
             printf("Enter day of birth of student:");
             scanf("%d",&(temp_student)->dateof_birth.day) ;
             printf("Enter month of birth of student:");
             scanf("%d",&(temp_student)->dateof_birth.month) ;
             printf("Enter year of birth of student:");
             scanf("%d",&(temp_student)->dateof_birth.year) ;
             printf("Enter score of student:");
             scanf("%d",&(temp_student)->Score);
             int i;
             t=clock(); //start the timer to count elapsed period
             for (i = n-1; i >0; i--) //start to move data by 1 place to empty room for the new data
                {
                 strcpy((students + i)->Name,(students + i-1)->Name);
                (students + i)->ID=(students + i-1)->ID;
                (students + i)->Score=(students + i-1)->Score;
                (students + i)->dateof_birth.day=(students + i-1)->dateof_birth.day;
                (students + i)->dateof_birth.month=(students + i-1)->dateof_birth.month;
                (students + i)->dateof_birth.year=(students + i-1)->dateof_birth.year;
                }
                //index will be equal to zero after loop(i=0), so we will copy the data of the new student from the temporary
                //variable to the empty slot in the structure
             strcpy((students + i)->Name,(temp_student)->Name);
            (students + i)->ID=(temp_student)->ID;
            (students + i)->Score=(temp_student)->Score;
            (students + i)->dateof_birth.day=(temp_student)->dateof_birth.day;
            (students + i)->dateof_birth.month=(temp_student)->dateof_birth.month;
            (students + i)->dateof_birth.year=(temp_student)->dateof_birth.year;
             t=clock()-t; //calculating elapsed time by subtracting the start from the end
             double Time_taken=((double)t)/CLOCKS_PER_SEC; //turning calculated time into seconds and storing it in a float variable
             printf("Time taken: %f\n\n",Time_taken); //print time
             break;
        }
        //the same is repeated here but for middle insertion
        case 2:{
            struct student *temp_student;
            int index;
            printf("Enter Index you want to insert at :");
            scanf("%d",&index);
            students=(struct student*)realloc(students, (n + 1) * sizeof(struct student));
            temp_student=(struct student*)(malloc(sizeof(struct student)));
             n++;
             printf("Enter name of student:");
             scanf("%s",&(temp_student)->Name) ;
             printf("Enter ID of student:");
             scanf("%d",&(temp_student)->ID) ;
             printf("Enter day of birth of student:");
             scanf("%d",&(temp_student)->dateof_birth.day) ;
             printf("Enter month of birth of student:");
             scanf("%d",&(temp_student)->dateof_birth.month) ;
             printf("Enter year of birth of student:");
             scanf("%d",&(temp_student)->dateof_birth.year) ;
             printf("Enter score of student:");
             scanf("%d",&(temp_student)->Score);
            int i;
            t=clock();
            for (i = n-1; i >index ; i--)
            {
                strcpy((students + i)->Name,(students + i-1)->Name);
                (students + i)->ID=(students + i-1)->ID;
                (students + i)->Score=(students + i-1)->Score;
                (students + i)->dateof_birth.day=(students + i-1)->dateof_birth.day;
                (students + i)->dateof_birth.month=(students + i-1)->dateof_birth.month;
                (students + i)->dateof_birth.year=(students + i-1)->dateof_birth.year;
            }
             strcpy((students + i)->Name,(temp_student)->Name);
            (students + i)->ID=(temp_student)->ID;
            (students + i)->Score=(temp_student)->Score;
            (students + i)->dateof_birth.day=(temp_student)->dateof_birth.day;
            (students + i)->dateof_birth.month=(temp_student)->dateof_birth.month;
            (students + i)->dateof_birth.year=(temp_student)->dateof_birth.year;
             t=clock()-t;
             double Time_taken=((double)t)/CLOCKS_PER_SEC;
             printf("Time taken: %f\n\n",Time_taken);
             break;
        }

        case 3:{
           struct student *temp_student;
           students=(struct student*)realloc(students, (n + 1) * sizeof(struct student));
           temp_student=(struct student*)(malloc(sizeof(struct student)));
             n++;
             printf("Enter name of student:");
             scanf("%s",&(temp_student)->Name) ;
             printf("Enter ID of student:");
             scanf("%d",&(temp_student)->ID) ;
             printf("Enter day of birth of student:");
             scanf("%d",&(temp_student)->dateof_birth.day) ;
             printf("Enter month of birth of student:");
             scanf("%d",&(temp_student)->dateof_birth.month) ;
             printf("Enter year of birth of student:");
             scanf("%d",&(temp_student)->dateof_birth.year) ;
             printf("Enter score of student:");
             scanf("%d",&(temp_student)->Score);
           int i=n-1;
           t=clock();
          strcpy((students + i)->Name,(temp_student)->Name);
            (students + i)->ID=(temp_student)->ID;
            (students + i)->Score=(temp_student)->Score;
            (students + i)->dateof_birth.day=(temp_student)->dateof_birth.day;
            (students + i)->dateof_birth.month=(temp_student)->dateof_birth.month;
            (students + i)->dateof_birth.year=(temp_student)->dateof_birth.year;
             t=clock()-t;
             double Time_taken=((double)t)/CLOCKS_PER_SEC;
             printf("\nTime taken: %f\n\n",Time_taken);
           break;
        }
    }
  }
}




