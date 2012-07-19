 class dirs::usr::local {
      
     
 file {
        "/usr/local":
            ensure => directory,
            mode => 0755;
    }
}  

