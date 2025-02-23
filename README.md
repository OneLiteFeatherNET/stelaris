# Stelaris UI

The Stelaris project is primarily aimed at facilitating the creation of various models, which are
subsequently translated into programming code. Model creation is facilitated through a user
interface (UI) developed using Flutter. Within this UI, a variety of widgets are available to aid in
model creation. Each model can be customized with different data, depending on its specific context.
Models that can be created are items, fonts, attributes and notifications. Each model has its 
own page within the UI, where the user can create, edit, and delete models. The sides 
may be divided into multiple parts. In the build page the user can generate the code.

## Home Page

## Model Pages
In the model pages, the user can create, edit, and delete models. Models are shown in a list
where the user can select a model to edit it. The user can also delete models from the list by
clicking on the delete button next to the model name. New models can be added by clicking on the
add button at the bottom of the list.

### Item Page
In the item page, the user can create, edit, and delete items. The page is divided into two parts.
The first is the general information of the item and the second is the item meta page.

### Font Page
In the font page, the user can create, edit, and delete fonts. The page is divided into two parts.
The first is the general information of the font. The second is the font meta page where the char
values are shown in a list. The user can add, edit, and delete char values.

### Attribute Page
In the attribute page, the user can create, edit, and delete attributes.

## Build Page
In the build the user can generate and download the code.


## How to run the App on your computer

To run the application on your local computer, follow these steps:

- **Install Flutter** – Ensure you have Flutter installed with the latest required version (**3.29.0**).
- **Modify the Environment Class** – Adjust the backend URL in the environment class to match your server setup.
- **Start the Backend Server** - Start the backend server
- **Run the App** – Start the application by pressing the **Start** button in your IDE or running:
  ```sh  
  flutter run  
  ```  

## Contributing

See the [CONTRIBUTING.md](CONTRIBUTING.md) file for more information.






