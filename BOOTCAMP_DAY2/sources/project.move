module MyModule::Microblog {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use std::string::String;
    use std::vector;

    /// Struct representing a single blog post
    struct Post has store, copy, drop {
        content: String,      // The blog post content
        timestamp: u64,       // When the post was created
        author: address,      // Address of the post author
    }

    /// Struct representing a user's microblog
    struct UserBlog has store, key {
        posts: vector<Post>,  // Vector storing all user's posts
        post_count: u64,      // Total number of posts by user
    }

    /// Function to initialize a new microblog for a user
    public fun create_blog(user: &signer) {
        let user_blog = UserBlog {
            posts: vector::empty<Post>(),
            post_count: 0,
        };
        move_to(user, user_blog);
    }

    /// Function to create a new blog post
    public fun create_post(
        author: &signer, 
        content: String
    ) acquires UserBlog {
        let author_addr = signer::address_of(author);
        let user_blog = borrow_global_mut<UserBlog>(author_addr);
        
        let new_post = Post {
            content,
            timestamp: timestamp::now_seconds(),
            author: author_addr,
        };
        
        vector::push_back(&mut user_blog.posts, new_post);
        user_blog.post_count = user_blog.post_count + 1;
    }

    /// Function to get the total number of posts by a user
    public fun get_post_count(user_addr: address): u64 acquires UserBlog {
        let user_blog = borrow_global<UserBlog>(user_addr);
        user_blog.post_count
    }
}