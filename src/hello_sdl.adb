with Ada.Text_IO;

with Interfaces.C;

with SDL;

with SDL.Events;
with SDL.Events.Events;
with SDL.Events.Keyboards;
with SDL.Events.Mice;

with SDL.Timers;

with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Surfaces;
with SDL.Video.Textures;
with SDL.Video.Textures.Makers;
with SDL.Video.Windows;
with SDL.Video.Windows.Makers;

with SDL.Images;
with SDL.Images.IO;

procedure Hello_SDL is

   Label    : constant String                  := "Hello SDL";
   Position : constant SDL.Natural_Coordinates :=
     (SDL.Video.Windows.Undefined_Window_Position (0), 500);
   Width  : constant := 1_200;
   Height : constant := 600;

   Window   : SDL.Video.Windows.Window;
   Renderer : SDL.Video.Renderers.Renderer;

   Background_Texture  : SDL.Video.Textures.Texture;
   Empty_Cell_Texture  : aliased SDL.Video.Textures.Texture;
   Filled_Cell_Texture : aliased SDL.Video.Textures.Texture;

   procedure Init_SDL is
   begin
      if not SDL.Initialise then
         raise Program_Error;
      end if;
      if not SDL.Images.Initialise then
         raise Program_Error;
      end if;
      SDL.Video.Windows.Makers.Create
        (Window, Label, Position, (Width, Height));
      SDL.Video.Renderers.Makers.Create (Renderer, Window);
   end Init_SDL;

   procedure Load_Image
     (Filename : String; Texture : in out SDL.Video.Textures.Texture)
   is
      Surface : SDL.Video.Surfaces.Surface;
   begin
      SDL.Images.IO.Create (Surface, Filename);
      SDL.Video.Textures.Makers.Create (Texture, Renderer, Surface);
   end Load_Image;

   procedure Init_Images is
   begin
      Load_Image ("gfx/SDLAda.png", Background_Texture);
      Load_Image ("gfx/empty_cell.png", Empty_Cell_Texture);
      Load_Image ("gfx/filled_cell.png", Filled_Cell_Texture);
   end Init_Images;

   procedure Apply_Surface
     (X, Y : SDL.Coordinate; Texture : SDL.Video.Textures.Texture)
   is
   -- Pixel_Size : constant SDL.Sizes := SDL.Video.Textures.Get_Size (Texture);
   -- use Pixel_Size.Width and .Height below instead of 60 to avoid stretching
      To : constant SDL.Video.Rectangles.Rectangle :=
        (X => X, Y => Y, Width => 60, Height => 60);
   begin
      SDL.Video.Renderers.Copy (Renderer, Texture, To);
   end Apply_Surface;

   procedure Shutdown_SDL is
   begin
      SDL.Images.Finalise;
      SDL.Finalise;
   end Shutdown_SDL;

   type X_Pos is range 1 .. 20;
   type Y_Pos is range 1 .. 10;

   type Cell_Status is (Clear, Filled);
   type Grid is array (X_Pos'Range, Y_Pos'Range) of Cell_Status;

   Board : Grid := (others => (others => Clear));

   procedure Update_Grid is
      use type Interfaces.C.int;
   begin
      for Y in Y_Pos'Range loop
         for X in X_Pos'Range loop
            declare
               X_Position : constant SDL.Coordinate :=
                 SDL.Coordinate (X - 1) * 60;
               Y_Position : constant SDL.Coordinate :=
                 SDL.Coordinate (Y - 1) * 60;
               Texture : constant access SDL.Video.Textures.Texture :=
                 (if Board (X, Y) = Filled then Filled_Cell_Texture'Access
                  else Empty_Cell_Texture'Access);
            begin
               Apply_Surface (X_Position, Y_Position, Texture.all);
            end;
         end loop;
      end loop;
   end Update_Grid;

   procedure Update_Display is
   begin
      Update_Grid;
      SDL.Video.Renderers.Copy (Renderer, Background_Texture);
   end Update_Display;

   type Main_Loop_Action is (Continue, Quit);

   function Handle_Key_Press
     (Key_Sym : SDL.Events.Keyboards.Key_Syms) return Main_Loop_Action
   is
      use SDL.Events.Keyboards;
      Key : constant Key_Codes := Key_Sym.Key_Code;
   begin
      case Key is
         when Code_Escape =>
            return Quit;
         when Code_0 =>
            Ada.Text_IO.Put_Line ("Pressed 0");
         when others =>
            Ada.Text_IO.Put_Line ("Pressed something");
      end case;
      return Continue;
   end Handle_Key_Press;

   procedure Handle_Click (X, Y : SDL.Natural_Coordinate) is
      use type Interfaces.C.int;
      X_Cell : constant X_Pos := X_Pos ((X / 60) + 1);
      Y_Cell : constant Y_Pos := Y_Pos ((Y / 60) + 1);
   begin
      Board (X_Cell, Y_Cell) := Filled;
      Ada.Text_IO.Put_Line ("Clicked at: " & X'Image & ", " & Y'Image);
   end Handle_Click;

   function Event_Handler
     (Event : SDL.Events.Events.Events) return Main_Loop_Action
   is
   begin
      case Event.Common.Event_Type is
         when SDL.Events.Keyboards.Key_Down =>
            if Handle_Key_Press (Event.Keyboard.Key_Sym) = Quit then
               return Quit;
            end if;
         when SDL.Events.Mice.Button_Down =>
            Handle_Click (Event.Mouse_Button.X, Event.Mouse_Button.Y);
         when SDL.Events.Quit =>
            return Quit;
         when others =>
            null;
      end case;
      return Continue;
   end Event_Handler;

   procedure Main_Loop is
      Event : SDL.Events.Events.Events;
   begin
      loop
         if SDL.Events.Events.Poll (Event) then
            if Event_Handler (Event) = Quit then
               return;
            end if;
         end if;
         Update_Display;
         SDL.Video.Renderers.Present (Renderer);
      end loop;
   end Main_Loop;

begin
   Init_SDL;
   Init_Images;
   Main_Loop;
   Shutdown_SDL;
end Hello_SDL;
