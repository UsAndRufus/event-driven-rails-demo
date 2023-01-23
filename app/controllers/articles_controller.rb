class ArticlesController < ApplicationController
  before_action :set_article, only: %i[ show edit update destroy ]
  before_action :auth, except: %i[ index show ]

  def index
    @articles = Article.all
  end

  def show
    @drafts = Rails.configuration.event_store
                   .read
                   .backward
                   .stream(stream_name(@article))
                   .of_type(Events::Articles::Drafted)
                   .to_a

    @drafts.map! do |draft|
      {
        author: User.find(draft.data[:user_id]).name,
        title: draft.data[:title],
        body: draft.data[:body],
        drafted_at: draft.metadata[:timestamp]
      }
    end
  end

  def new
    @article = Article.new
  end

  def edit
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      publish_draft_event

      redirect_to article_url(@article), notice: "Article drafted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @article.update(article_params)
      publish_draft_event

      redirect_to article_url(@article), notice: "Article was drafted."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
    @article.destroy

    redirect_to articles_url, notice: "Article was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_article
    @article = Article.find(params[:id])
  end

  def auth
    redirect_to articles_path, alert: 'Modifying articles is only available to authors and editors' unless @user.present?
  end

    # Only allow a list of trusted parameters through.
  def article_params
    params.require(:article).permit(:title, :body)
  end

  def publish_draft_event
    event = Events::Articles::Drafted.new(data: { article_id: @article.id, user_id: @user.id,
                                                  title: article_params[:title], body: article_params[:body] })

    Rails.configuration.event_store.publish(event, stream_name: stream_name(@article))
  end
end
