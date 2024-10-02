defmodule TranshookWeb.ModalComponent do
  use TranshookWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div id={@id} class="phx-modal"
        phx-capture-click="close"
        phx-window-keydown="close"
        phx-key="escape"
        phx-target="#{@id}"
        phx-page-loading>

        <div class="phx-modal-content">
          <%= live_patch raw("&times;"), to: @return_to, class: "phx-modal-close" %>
          <%= live_component @component, @opts %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
