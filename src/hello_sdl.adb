with Ada.Text_IO;

with SDL;
with SDL.Events;
with SDL.Events.Events;
with SDL.Events.Keyboards;
with SDL.Timers;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;
with SDL.Video.Windows.Makers;

with SDL.Images;

procedure Hello_SDL is

   Label    : constant String                  := "Hello SDL";
   Position : constant SDL.Natural_Coordinates :=
     (SDL.Video.Windows.Undefined_Window_Position (0), 100);
   Width  : constant := 400;
   Height : constant := 300;

   Window   : SDL.Video.Windows.Window;
   Renderer : SDL.Video.Renderers.Renderer;

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

   procedure Shutdown_SDL is
   begin
      SDL.Images.Finalise;
      SDL.Finalise;
   end Shutdown_SDL;

   procedure Update_Display is
   begin
      null;
   end Update_Display;

   procedure Main_Loop is
      Event : SDL.Events.Events.Events;
   begin
      loop
         if SDL.Events.Events.Poll (Event) then
            case Event.Common.Event_Type is
               when SDL.Events.Keyboards.Key_Down =>
                  declare
                     use type SDL.Events.Keyboards.Key_Codes;
                     use SDL.Events.Keyboards;
                     Key : constant Key_Codes :=
                       Event.Keyboard.Key_Sym.Key_Code;
                  begin
                     case Key is
                        when Code_Escape =>
                           return;
                        when Code_0 =>
                           Ada.Text_IO.Put_Line ("Pressed 0");
                        when others =>
                           Ada.Text_IO.Put_Line ("Pressed something");
                     end case;
                  end;
               when SDL.Events.Quit =>
                  return;
               when others =>
                  null;
            end case;
         end if;
         Update_Display;
      end loop;
   end Main_Loop;

begin
   Init_SDL;
   Main_Loop;
   Shutdown_SDL;
end Hello_SDL;
